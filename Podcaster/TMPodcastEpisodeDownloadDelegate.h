//
//  TMPodcastEpisodeDownloadDelegate.h
//  Podcaster
//
//  Created by Tyler Mikev on 7/10/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

@protocol TMPodcastEpisodeDelegate;

@protocol TMPodcastEpisodeDownloadDelegate <NSObject>
- (void)startDownloadForEpisode:(id<TMPodcastEpisodeDelegate>)episode;
- (void)stopDownloadForEpisode:(id<TMPodcastEpisodeDelegate>)episode;
- (void)deleteDownloadForEpisode:(id<TMPodcastEpisodeDelegate>)episode;
@end
