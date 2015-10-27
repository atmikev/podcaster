//
//  TMPodcastEpisodesTableViewCell.h
//  Podcaster
//
//  Created by Tyler Mikev on 3/7/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMPodcastEpisode;
@class UAProgressView;
@protocol TMPodcastEpisodeDelegate;
@protocol TMPodcastEpisodeDownloadDelegate;

typedef NS_ENUM(NSUInteger, TMDownloadState) {
    TMDownloadStateNotDownloading,
    TMDownloadStateDownloading,
    TMDownloadStateCompleted,
};

@interface TMPodcastEpisodesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishDateLabel;
@property (weak, nonatomic) IBOutlet UAProgressView *progressView;
@property (strong, nonatomic) NSObject<TMPodcastEpisodeDelegate> *episode;
@property (weak, nonatomic) id<TMPodcastEpisodeDownloadDelegate> downloadDelegate;
@property (assign, nonatomic) TMDownloadState downloadState;

- (void)updateProgressView:(CGFloat)progress;
@end
