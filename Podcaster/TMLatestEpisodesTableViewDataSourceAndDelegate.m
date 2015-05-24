//
//  TMLatestEpisodesTableViewDataSource.m
//  Podcaster
//
//  Created by Tyler Mikev on 5/23/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMLatestEpisodesTableViewDataSourceAndDelegate.h"
#import "TMPodcastLatestEpisodeTableViewCell.h"
#import "TMPodcastEpisode.h"
#import "TMPodcastProtocol.h"
#import "TMSelectPodcastEpisodeProtocol.h"

@interface TMLatestEpisodesTableViewDataSourceAndDelegate ()

@property (weak, nonatomic) id<TMSelectPodcastEpisodeDelegate> delegate;

@end

@implementation TMLatestEpisodesTableViewDataSourceAndDelegate

- (instancetype)initWithDelegate:(id<TMSelectPodcastEpisodeDelegate>)delegate {
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
    return self.subscribedEpisodesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TMPodcastLatestEpisodeTableViewCell *cell = (TMPodcastLatestEpisodeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kLatestEpisodeCellReuseIdentifier forIndexPath:indexPath];
    
    TMPodcastEpisode *podcastEpisode = [self.subscribedEpisodesArray objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = podcastEpisode.title;
    cell.durationLabel.text = podcastEpisode.durationString;
    cell.publishDateLabel.text = podcastEpisode.publishDateString;
    
    if (podcastEpisode.podcast.podcastImage) {
        cell.podcastImageView.image = podcastEpisode.podcast.podcastImage;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TMPodcastEpisode *episode = [self.subscribedEpisodesArray objectAtIndex:indexPath.row];
    [self.delegate didSelectEpisode:episode];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 65;
}

@end
