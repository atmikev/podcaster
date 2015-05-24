//
//  TMSelectPodcastEpisodeProtocol.h
//  Podcaster
//
//  Created by Tyler Mikev on 5/23/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

@class TMPodcastEpisode;

@protocol TMSelectPodcastEpisodeDelegate <NSObject>

- (void)didSelectEpisode:(TMPodcastEpisode *)episode;

@end
