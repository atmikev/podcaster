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
#import "TMSubscribedEpisode.h"

@interface TMLatestEpisodesTableViewDataSourceAndDelegate ()

@property (weak, nonatomic) id<TMSelectPodcastEpisodeDelegate> delegate;
@property (strong, nonatomic) NSArray *heardEpisodesArray;
@property (strong, nonatomic) NSArray *unheardEpisodesArray;
@end

@implementation TMLatestEpisodesTableViewDataSourceAndDelegate

- (instancetype)initWithDelegate:(id<TMSelectPodcastEpisodeDelegate>)delegate {
    self = [super init];
    
    if (self) {
        _delegate = delegate;
    }
    
    return self;
}

- (void)setSubscribedEpisodesArray:(NSArray *)subscribedEpisodesArray {
    //sort the array to see which episodes have been listened to or not
    NSMutableArray *heardMutableArray = [NSMutableArray new];
    NSMutableArray *unheardMutableArray = [NSMutableArray new];
    
    for (TMSubscribedEpisode *episode in subscribedEpisodesArray) {
        if (episode.lastPlayLocation == nil) {
            [unheardMutableArray addObject:episode];
        } else {
            [heardMutableArray addObject:episode];
        }
    }
    
    //sort both arrays by publish date
    NSArray *sortDescriptorArray = @[[NSSortDescriptor sortDescriptorWithKey:@"publishDate" ascending:NO]];
    self.heardEpisodesArray = [heardMutableArray sortedArrayUsingDescriptors:sortDescriptorArray];
    self.unheardEpisodesArray = [unheardMutableArray sortedArrayUsingDescriptors:sortDescriptorArray];
    
}

- (NSArray *)arrayForSection:(NSInteger)section {
    NSArray *array = nil;
    if (section == 0) {
        array = self.unheardEpisodesArray;
    } else if (section == 1) {
        array = self.heardEpisodesArray;
    }
    
    return array;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [[self arrayForSection:section] count];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TMPodcastLatestEpisodeTableViewCell *cell = (TMPodcastLatestEpisodeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kLatestEpisodeCellReuseIdentifier forIndexPath:indexPath];
    
    TMPodcastEpisode *podcastEpisode = [[self arrayForSection:indexPath.section] objectAtIndex:indexPath.row];
    
    if (podcastEpisode.podcast.podcastImage) {
        cell.podcastImageView.image = podcastEpisode.podcast.podcastImage;
    }
    
    [cell setupCellWithEpisode:podcastEpisode];
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TMPodcastEpisode *podcastEpisode = [[self arrayForSection:indexPath.section] objectAtIndex:indexPath.row];
    [self.delegate didSelectEpisode:podcastEpisode];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    
    if (section == 0) {
        title = @"Fresh!";
    } else {
        title = @"Already Heard";
    }
    
    return title;
}


@end
