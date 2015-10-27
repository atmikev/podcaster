//
//  TMAllEpisodesTableViewDataSource.h
//  Podcaster
//
//  Created by Tyler Mikev on 5/23/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TMSelectPodcastDelegate;
@protocol TMPodcastEpisodeDownloadDelegate;

@interface TMAllEpisodesTableViewDataSourceAndDelegate : NSObject <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) NSArray *subscribedPodcasts;
@property (strong, nonatomic) id<TMPodcastEpisodeDownloadDelegate> downloadDelegate;

- (instancetype)initWithDelegate:(id<TMSelectPodcastDelegate>)delegate;

@end
