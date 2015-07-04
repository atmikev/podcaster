//
//  TMPodcastEpisodesTableViewCell.m
//  Podcaster
//
//  Created by Tyler Mikev on 3/7/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMPodcastEpisodesTableViewCell.h"
#import "TMPodcastEpisode.h"
#import "NSString+Formatter.h"

@implementation TMPodcastEpisodesTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.preferredMaxLayoutWidth = 250;
}

- (void)setupCellWithEpisode:(TMPodcastEpisode *)episode {
    self.titleLabel.text = episode.title;
    
    self.durationLabel.text = [NSString durationStringFromDuration:episode.duration];
    [self.durationLabel sizeToFit];
    
    self.publishDateLabel.text = [NSString publishDateStringFromPublishDate:episode.publishDate];

    self.progressView.hidden = YES;
    
    if (episode.fileLocation) {
        self.downloadedImageView.hidden = NO;
    } else {
        self.downloadedImageView.hidden = YES;
    }
}

@end
