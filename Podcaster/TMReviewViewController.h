//
//  TMReviewViewController.h
//  Podcaster
//
//  Created by Tyler Mikev on 5/18/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMPodcastEpisode;

@interface TMReviewViewController : UIViewController

@property (strong, nonatomic) TMPodcastEpisode *episode;
@property (assign, nonatomic) NSTimeInterval episodeTime;
@property (assign, nonatomic) BOOL initiatedByUser;

@end
