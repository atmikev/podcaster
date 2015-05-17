//
//  TMPodcastEpisodeHeaderTableViewCell.m
//  Podcaster
//
//  Created by Tyler Mikev on 4/4/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMPodcastEpisodeHeaderTableViewCell.h"
#import "TMPodcast.h"

@interface TMPodcastEpisodeHeaderTableViewCell ()

@property (strong, nonatomic) TMPodcast *podcast;

@end

@implementation TMPodcastEpisodeHeaderTableViewCell

- (void)awakeFromNib {
    //make sure the textview starts at the top
    [self.descriptionTextView scrollRangeToVisible:NSMakeRange(0, 1)];
}

- (void)setupCellWithPodcast:(TMPodcast *)podcast {
    self.podcast = podcast;
    self.podcastImageView.image = podcast.podcastImage;
    self.titleLabel.text = podcast.title;
    self.descriptionTextView.text = podcast.podcastDescription;
}

#pragma mark - Button Handlers

- (IBAction)subscribeButtonHandler:(id)sender {
    [self.subscriptionDelegate subscribeToPodcast:self.podcast];
}


@end
