//
//  TMPodcastLatestEpisodeTableViewCell.h
//  Podcaster
//
//  Created by Tyler Mikev on 5/20/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMPodcastEpisodesTableViewCell.h"

static NSString * const kLatestEpisodeCellReuseIdentifier = @"latestEpisodeCell";

@interface TMPodcastLatestEpisodeTableViewCell : TMPodcastEpisodesTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *podcastImageView;
@property (weak, nonatomic) IBOutlet UIButton *allEpisodesButton;


@end
