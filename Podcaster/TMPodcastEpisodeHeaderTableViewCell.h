//
//  TMPodcastEpisodeHeaderTableViewCell.h
//  Podcaster
//
//  Created by Tyler Mikev on 4/4/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMPodcast;

@interface TMPodcastEpisodeHeaderTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *podcastImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

- (void)setupCellWithPodcast:(TMPodcast *)podcast;

@end
