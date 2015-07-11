//
//  TMLatestEpisodesTableViewDataSource.h
//  Podcaster
//
//  Created by Tyler Mikev on 5/23/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TMPodcastEpisode;
@protocol TMSelectPodcastEpisodeDelegate;
@protocol TMDownloadDelegate;
@protocol TMPodcastEpisodeDownloadDelegate;

@interface TMLatestEpisodesTableViewDataSourceAndDelegate : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *subscribedEpisodesArray;
@property (strong, nonatomic) id<TMPodcastEpisodeDownloadDelegate> downloadDelegate;
@property (strong, nonatomic) UITableView *tableView;

- (instancetype)initWithDelegate:(id<TMSelectPodcastEpisodeDelegate>)delegate;

@end
