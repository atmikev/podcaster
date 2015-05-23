//
//  TMPodcastEpisodesTableViewCell.m
//  Podcaster
//
//  Created by Tyler Mikev on 3/7/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMPodcastEpisodesTableViewCell.h"
#import "TMPodcastEpisode.h"

@implementation TMPodcastEpisodesTableViewCell

- (void)setupCellWithEpisode:(TMPodcastEpisode *)episode {
    self.titleLabel.text = episode.title;
    
    self.durationLabel.text = episode.durationString;
    
    self.publishDateLabel.text = episode.publishDateString;
    
    self.progressView.hidden = YES;
    
    if (episode.fileLocation) {
        self.downloadedImageView.hidden = NO;
    } else {
        self.downloadedImageView.hidden = YES;
    }
}

@end
