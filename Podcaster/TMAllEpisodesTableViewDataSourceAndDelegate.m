//
//  TMAllEpisodesTableViewDataSource.m
//  Podcaster
//
//  Created by Tyler Mikev on 5/23/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMAllEpisodesTableViewDataSourceAndDelegate.h"
#import <UIKit/UIKit.h>
#import "TMSelectPodcastProtocol.h"
#import "TMPodcastTableViewCell.h"
#import "TMPodcast.h"
#import "TMPodcastProtocol.h"

@interface TMAllEpisodesTableViewDataSourceAndDelegate ()

@property (weak, nonatomic) id<TMSelectPodcastDelegate> delegate;

@end


@implementation TMAllEpisodesTableViewDataSourceAndDelegate

- (instancetype)initWithDelegate:(id<TMSelectPodcastDelegate>)delegate {
    self = [super init];
    
    if (self) {
        _delegate = delegate;
    }
    
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.subscribedPodcasts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TMPodcastTableViewCell *cell = (TMPodcastTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kPodcastCellReuseIdentifier forIndexPath:indexPath];
    
    TMPodcast *podcast = [self.subscribedPodcasts objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = podcast.title;
    
    if (podcast.podcastImage) {
        cell.podcastImageView.image = podcast.podcastImage;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TMPodcast *podcast = [self.subscribedPodcasts objectAtIndex:indexPath.row];
    [self.delegate didSelectPodcast:podcast];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 65;
}

@end
