//
//  TMDeleteOperation.h
//  Podcaster
//
//  Created by Tyler Mikev on 7/11/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TMPodcastEpisodeDelegate;

@interface TMDeleteOperation : NSOperation

- (instancetype)initWithEpisode:(id<TMPodcastEpisodeDelegate>)episode;

@end
