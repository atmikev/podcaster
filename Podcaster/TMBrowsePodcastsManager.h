//
//  TMBrowsePodcastsManager.h
//  Podcaster
//
//  Created by Tyler Mikev on 6/13/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMGenre;

@interface TMBrowsePodcastsManager : NSObject

//Gets all the genre's (but not subgenres) that iTunes lists
- (void)retrieveGenresDictionaryWithSuccessBlock:(void(^)(NSArray *genresArray))successBlock
                                 andFailureBlock:(void(^)(NSError *error))failureBlock;

//Gets the top audio podcasts for a genre
- (void)retrieveTopPodcastsForGenre:(TMGenre *)genre
                   withSuccessBlock:(void(^)(NSArray *podcastsArray))successBlock
                    andFailureBlock:(void(^)(NSError *error))failureBlock;

@end
