//
//  TMDeeplinkManager.m
//  Podcaster
//
//  Created by max blessen on 11/11/15.
//  Copyright © 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMDeeplinkManager.h"
#import "TMPodcastsManager.h"
#import "TMPodcast.h"
#import "TMPodcastEpisode.h"
#import "TMSelectPodcastEpisodeProtocol.h"
#import "TMiTunesResponse.h"
#import "TMMainTabBarController.h"
#import "AppDelegate.h"
#import "TMPodcastProtocol.h"
#import "TMSelectPodcastEpisodeProtocol.h"

@interface TMDeeplinkManager ()

@property (weak, nonatomic) id<TMPodcastDelegate> podcast;
@property (weak, nonatomic) id<TMSelectPodcastEpisodeDelegate> delegate;

@end



@implementation TMDeeplinkManager


- (instancetype)initWithDelegate:(id<TMSelectPodcastEpisodeDelegate>)delegate {

    self = [super init];
    
    if (self) {
        _delegate = delegate;
    }
    
    return self;
}

+ (void)searchForPodcastWithCollectionID:(NSNumber *)collectionID
                                   title:(NSString *)title
                             andDelegate:(id<TMSelectPodcastEpisodeDelegate>)delegate {

    [self podcastFromPodcastCollectionId:collectionID
                        withSuccessBlock:^(TMPodcast *podcast) {
        
        NSString *decodedEpisodeTitle = [podcast.title stringByRemovingPercentEncoding];
                            
        TMPodcastsManager *podcastsManager = [TMPodcastsManager new];
                            
        [podcastsManager podcastEpisodesAtURL:podcast.feedURLString
                             withSuccessBlock:^(TMPodcast *podcast) {
                                 NSArray *episodes = podcast.episodes;
                          
                                 for (TMPodcastEpisode *episode in episodes) {
                                     
                                    NSString *podcastEpisodeTitle = episode.title;
                                     
                                    if ([podcastEpisodeTitle isEqualToString:title]) {
                                        
                                        [delegate didSelectEpisode:episode];
                                        
                                    }
                                }
            
        }andFailureBlock:^(NSError *error) {
            NSLog(@"Error: Failed to get retrieve podcast episodes: %@", error.debugDescription);
        }];
        
    }andFailureBlock:^(NSError *error){
        NSLog(@"Error: Failed to get podcast details: %@", error.debugDescription);
    }];
    
}

- (void)podcastFromPodcastCollectionId:(NSNumber *)collectionId
                      withSuccessBlock:(void (^)(TMPodcast *))successBlock
                       andFailureBlock:(void (^)(NSError *))failureBlock {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@", collectionId]];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:url
                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error != nil && failureBlock) {
            failureBlock(error);
        } else {
            
            if (data) {
                NSError *jsonError;
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                
                if (jsonError != nil && failureBlock) {
                    failureBlock(error);
                } else {
                    
                    NSDictionary *resultDictionary = [[responseDictionary objectForKey:@"results"] firstObject];
                    
                    TMiTunesResponse *iTunesResponse = [TMiTunesResponse iTunesResponseFromDictionary:resultDictionary];
                    
                    TMPodcast *podcast = [TMPodcast initWithiTunesResponse:iTunesResponse];
                    
                    if (successBlock) {
                        successBlock(podcast);
                    }
                }
            }
            
        }
    }] resume];
}

+ (void)podcastFromPodcastCollectionId:(NSNumber *)collectionId
                      withSuccessBlock:(void (^)(TMPodcast *))successBlock
                       andFailureBlock:(void (^)(NSError *))failureBlock {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@", collectionId]];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error != nil && failureBlock) {
            failureBlock(error);
        } else {
            
            if (data) {
                NSError *jsonError;
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if (jsonError != nil && failureBlock) {
                    failureBlock(error);
                } else {
                    NSDictionary *resultDictionary = [[responseDictionary objectForKey:@"results"] firstObject];
                    
                    TMiTunesResponse *iTunesResponse = [TMiTunesResponse iTunesResponseFromDictionary:resultDictionary];
                    TMPodcast *podcast = [TMPodcast initWithiTunesResponse:iTunesResponse];
                    
                    if (successBlock) {
                        successBlock(podcast);
                    }
                }
            }
            
        }
    }] resume];
}




@end



