//
//  TMAudioPlayerViewController.h
//  Podcaster
//
//  Created by Tyler Mikev on 3/10/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TMPodcastEpisodeDelegate;

@interface TMAudioPlayerViewController : UIViewController

@property (strong, nonatomic) id<TMPodcastEpisodeDelegate> episode;
@property (strong, nonatomic) UIImage *podcastImage;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
