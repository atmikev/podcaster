//
//  TMSearchResultsTableViewController.h
//  Podcaster
//
//  Created by Tyler Mikev on 4/12/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TMSelectPodcastDelegate;

@interface TMSearchResultsTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *podcastsArray;
@property (weak, nonatomic) id<TMSelectPodcastDelegate> delegate;

@end

