//
//  TMPodcastEpisodeHeaderTableViewCell.h
//  Podcaster
//
//  Created by Tyler Mikev on 4/4/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMPodcastSubscriptionDelegate.h"

@class TMPodcast;

@protocol TMPodcastEpisodeHeaderProtocol;
@protocol TMPodcastDelegate;

@interface TMPodcastEpisodeHeaderTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *podcastImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *subscribeButton;
@property (weak, nonatomic) IBOutlet UILabel *subscribedLabel;
@property (weak, nonatomic) id<TMPodcastSubscriptionDelegate> subscriptionDelegate;

- (void)setupCellWithPodcast:(id<TMPodcastDelegate>)podcast;

- (IBAction)subscribeButtonHandler:(id)sender;


@end
