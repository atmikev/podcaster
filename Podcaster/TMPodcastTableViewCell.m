//
//  TMPodcastTableViewCell.m
//  Podcaster
//
//  Created by Tyler Mikev on 3/13/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMPodcastTableViewCell.h"

@implementation TMPodcastTableViewCell

- (void)prepareForReuse {
    self.titleLabel.text = @"";
    self.podcastImageView.image = nil;
}

@end
