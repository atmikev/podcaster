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

@interface TMLatestEpisodesTableViewDataSourceAndDelegate : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *subscribedEpisodesArray;

- (instancetype)initWithDelegate:(id<TMSelectPodcastEpisodeDelegate>)delegate;

@end
