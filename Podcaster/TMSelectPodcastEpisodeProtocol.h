//
//  TMSelectPodcastEpisodeProtocol.h
//  Podcaster
//
//  Created by Tyler Mikev on 5/23/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

@class TMPodcastEpisode;
@protocol TMPodcastEpisodeDelegate;

@protocol TMSelectPodcastEpisodeDelegate <NSObject>

- (void)didSelectEpisode:(id<TMPodcastEpisodeDelegate>)episode;

@end
