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

@interface TMDeeplinkManager ()

@property (strong, nonatomic) NSArray *episodes;
@property (strong, nonatomic) TMPodcastEpisode *deepLinkEpisode;

@end


@implementation TMDeeplinkManager

@synthesize delegate;

-(void)searchForPodcast:(NSNumber *)collectionId forTitle:(NSString *)title {
    NSLog(@"%@", collectionId);
    NSLog(@"%@", title);
    [self podcastFromPodcastCollectionId:collectionId withSuccessBlock:^(TMPodcast *podcast) {
    
        NSString *decodedEpisodeTitle = [podcast.title stringByRemovingPercentEncoding];
        NSLog(@"%@", decodedEpisodeTitle);
        TMPodcastsManager *podcastsManager = [[TMPodcastsManager alloc] init];
        [podcastsManager podcastEpisodesAtURL:podcast.feedURLString withSuccessBlock:^(TMPodcast *podcast) {
            NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"publishDate" ascending:NO];
            self.episodes = [[podcast.episodes allObjects] sortedArrayUsingDescriptors:@[dateDescriptor]];
            self.podcast.episodes = [NSSet setWithArray:self.episodes];
            for (TMPodcastEpisode *episode in self.episodes) {
                NSString *podcastEpisodeTitle = episode.title;
                if ([podcastEpisodeTitle isEqualToString:title]) {
                    NSLog(@"FOUND IT");
                    NSLog(@"%@", podcastEpisodeTitle);
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    TMMainTabBarController *mainTabBarController = (TMMainTabBarController *)appDelegate.window.rootViewController;
                    self.delegate = mainTabBarController;
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
    //probably should do this by podcast ID, but searching by the string that came back in the Browse response for now
    
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



