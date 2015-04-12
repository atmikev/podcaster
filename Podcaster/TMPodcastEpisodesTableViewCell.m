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
    
    NSInteger minutes = episode.duration / 60;
    self.durationLabel.text = [NSString stringWithFormat:@"%ld min", (long)minutes];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM d, YYYY"];
    self.publishDateLabel.text = [dateFormatter stringFromDate:episode.publishDate];
    
    self.progressView.hidden = YES;
    
    if (episode.fileLocation) {
        self.downloadedImageView.hidden = NO;
    } else {
        self.downloadedImageView.hidden = YES;
    }
}

@end
