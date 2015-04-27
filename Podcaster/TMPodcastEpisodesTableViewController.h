//
//  TMPodcastEpisodesTableViewController.h
//  Podcaster
//
//  Created by Tyler Mikev on 3/7/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMPodcastProtocol.h"

@interface TMPodcastEpisodesTableViewController : UITableViewController

@property (strong, nonatomic) id<TMPodcastDelegate> podcast;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
