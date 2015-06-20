//
//  TMBrowsePodcastsManager.m
//  Podcaster
//
//  Created by Tyler Mikev on 6/13/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMBrowsePodcastsManager.h"

#import "TMGenre.h"
#import "TMPodcast.h"
#import "TMiTunesResponse.h"
#import "TMBrowsePodcastResponse.h"
#import "TMPodcastsManager.h"
#import "TMDownloadManager.h"

static NSString * const kGenresDictionaryURLString = @"http://itunes.apple.com/WebObjects/MZStoreServices.woa/ws/genres";
static NSString * const kPodcastGenreID = @"26";
static NSString * const kSubgenresKey = @"subgenres";
static NSString * const kNameKey = @"name";
static NSString * const kRSSURLKey = @"rssUrls";
static NSString * const kTopAudioPodcastsKey = @"topAudioPodcasts";

@implementation TMBrowsePodcastsManager

- (void)retrieveGenresDictionaryWithSuccessBlock:(void(^)(NSArray *genresArray))successBlock
                                 andFailureBlock:(void(^)(NSError *error))failureBlock {

    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    [[session dataTaskWithURL:[NSURL URLWithString:kGenresDictionaryURLString]
           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
               if (error && failureBlock) {
                   failureBlock(error);
                   return;
               }
               
               NSError *jsonError;
               NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
               if (jsonError && failureBlock) {
                   failureBlock(jsonError);
                   return;
               }
               
               //figure out which genres iTunes is currently listing.
               NSArray *genresArray = [self extractGenreInfoFromDictionary:responseDictionary];
               if (successBlock) {
                   successBlock(genresArray);
               }
    }] resume];
    
    
}

- (NSArray *)extractGenreInfoFromDictionary:(NSDictionary *)responseDictionary {
    NSDictionary *genresDictionary = [[responseDictionary objectForKey:kPodcastGenreID] objectForKey:kSubgenresKey];

    NSMutableArray *extractedGenresArray = [NSMutableArray new];
    for (NSString *key in [genresDictionary allKeys]) {
        NSDictionary *dictionary = [genresDictionary objectForKey:key];

        //grab the relevant dictionary info and make a new dictionary
        TMGenre *genre = [TMGenre genreWithName:dictionary[kNameKey] andURL:dictionary[kRSSURLKey][kTopAudioPodcastsKey]];
        
        //add that dictionary to our list of extractedGenreDictionary
        [extractedGenresArray addObject:genre];
    }

    return [extractedGenresArray copy];
}

- (void)retrieveImagesForPodcasts:(NSArray *)podcastsArray withGenre:(TMGenre *)genre andCompletionBlock:(void(^)(NSArray *podcastsArray))successBlock {
    __block NSInteger count = 0;
    
    for (TMPodcast *podcast in podcastsArray) {
        NSURL *imageURL = nil;
        
        //this is gross. do it better
        if ([genre.name isEqualToString:@"Popular"]) {
            imageURL = podcast.image600URL;
        } else {
            imageURL = podcast.image170URL;
        }
        
        [TMDownloadManager downloadImageAtURL:imageURL withCompletionBlock:^(UIImage *image) {
            //store whatever image we downloaded as this podcast object's image
            podcast.podcastImage = image;
            
            //call the successBlock if its time
            count++;
            if (successBlock && count == podcastsArray.count) {
                successBlock(podcastsArray);
            }
        }];
        
    }
}

- (void)retrieveTopPodcastsForGenre:(TMGenre *)genre
                withSuccessBlock:(void(^)(NSArray *podcastsArray))successBlock
                    andFailureBlock:(void(^)(NSError *error))failureBlock {
   
    if ([genre.name isEqualToString:@"Popular"]) {
        //popular genre
        
        [self retrieveTopPodcastsWithCount:25
                          withSuccessBlock:^(NSArray *podcastsArray) {
            
            [self retrieveImagesForPodcasts:podcastsArray
                                  withGenre:genre
                         andCompletionBlock:successBlock];
            
        } withFailureBlock:^(NSError *error) {
            NSLog(@"Error getting popular podcasts:%@", error.debugDescription);
        }];
    } else {
        //regular genre
        
        [self retrieveBrowseModelPodcastsWithURL:genre.urlString
                                withSuccessBlock:^(NSArray *podcastsArray) {
                                    
                                    [self retrieveImagesForPodcasts:podcastsArray
                                                          withGenre:genre
                                                 andCompletionBlock:successBlock];
                                    
                                } withFailureBlock:failureBlock];
    }
    
    
    
}

- (void)retrieveBrowseModelPodcastsWithURL:(NSString *)urlString
                          withSuccessBlock:(void(^)(NSArray *podcastsArray))successBlock
                          withFailureBlock:(void(^)(NSError *error))failureBlock {

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURL *url = [NSURL URLWithString:urlString];
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error && failureBlock) {
            failureBlock(error);
            return;
        }
        
        NSError *jsonError;
        //this is a little compact, but we're just getting the dictionary from the returned object's [feed][entry] value
        NSArray *podcastsArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError][@"feed"][@"entry"];
        if (jsonError && failureBlock) {
            failureBlock(jsonError);
            return;
        }
        
        NSMutableArray *podcastsMutableArray = [NSMutableArray new];
        __block NSInteger count = 0;
        NSInteger total = [podcastsArray count];
        TMPodcastsManager *podcastsManager = [TMPodcastsManager new];
        for (NSDictionary *browseDictionary in podcastsArray) {
            TMBrowsePodcastResponse *browseResponse = [TMBrowsePodcastResponse initWithDictionary:browseDictionary];
            
            [podcastsManager podcastFromBrowsePodcastResponse:browseResponse withSuccessBlock:^(TMPodcast *podcast) {

                //store the image170URL
                podcast.image170URL = [NSURL URLWithString:browseResponse.image170URLString];
                [podcastsMutableArray addObject:podcast];
                
                //increment the count
                count++;
                if (count == total && successBlock) {
                    successBlock([podcastsMutableArray copy]);
                }
            } andFailureBlock:^(NSError *error) {
                NSLog(@"Error retrieving podcast from browse response:%@",error.debugDescription);
                
                count++;
                if (count == total && successBlock) {
                    successBlock([podcastsMutableArray copy]);
                }
            }];
        }
        
    }] resume];
}

- (void)retrieveTopPodcastsWithCount:(NSInteger)maxNumPodcasts
                    withSuccessBlock:(void(^)(NSArray *podcastsArray))successBlock
                    withFailureBlock:(void(^)(NSError *error))failureBlock {
    
    NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/us/rss/toppodcasts/limit=%ld/explicit=true/json", (long)maxNumPodcasts];
    [self retrieveBrowseModelPodcastsWithURL:urlString withSuccessBlock:successBlock withFailureBlock:failureBlock];
}

@end
