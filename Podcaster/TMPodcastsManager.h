//
//  TMPodcastsManager.h
//  Podcaster
//
//  Created by Tyler Mikev on 3/7/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class TMPodcast;
@class TMPodcastEpisode;
@class TMBrowsePodcastResponse;
@protocol TMPodcastEpisodeDelegate;

@interface TMPodcastsManager : NSObject

- (void)podcastEpisodesAtURL:(NSString *)urlString
               withSuccessBlock:(void(^)(TMPodcast *podcast))successBlock
                andFailureBlock:(void(^)(NSError *error))failureBlock;

- (void)downloadPodcastEpisodeAtURL:(NSString *)episodeURLString
                       withFileName:(NSString *)fileName
                        updateBlock:(void(^)(CGFloat downloadPercentage))updateBlock
                       successBlock:(void(^)(NSString *filePath))successBlock
                    andFailureBlock:(void(^)(NSError *error))failureBlock;

- (void)deletePodcastEpisode:(id<TMPodcastEpisodeDelegate>)episode;

- (void)cancelDownloadForPodcastEpisode:(id<TMPodcastEpisodeDelegate>)episode;

- (void)podcastFromBrowsePodcastResponse:(TMBrowsePodcastResponse *)browsePodcastResponse
                        withSuccessBlock:(void(^)(TMPodcast *podcast))successBlock
                         andFailureBlock:(void(^)(NSError *error))failureBlock;

- (void)searchForPodcastsWithSearchString:(NSString *)searchString
                               maxResults:(NSInteger)maxResults
                             successBlock:(void(^)(NSArray *podcasts))successBlock
                          andFailureBlock:(void(^)(NSError *error))failureBlock;

- (void)topPodcastsWithSuccessBlock:(void(^)(NSArray *podcasts))successBlock
                    andFailureBlock:(void(^)(NSError *error))failureBlock;

- (NSString *)filePathForEpisode:(TMPodcastEpisode *)episode;

@end
