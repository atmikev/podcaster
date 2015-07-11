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
#import "TMPodcastEpisodeDownloadDelegate.h"
#import "TMDownloadOperation.h"
#import "TMPodcastEpisodeProtocol.h"
#import "TMPodcastsManager.h"

@interface TMLatestEpisodesTableViewDataSourceAndDelegate () <TMPodcastEpisodeDownloadDelegate>

@property (weak, nonatomic) id<TMSelectPodcastEpisodeDelegate> delegate;
@property (strong, nonatomic) NSArray *heardEpisodesArray;
@property (strong, nonatomic) NSArray *unheardEpisodesArray;
@property (strong, nonatomic) TMPodcastsManager *podcastsManager;
@end

@implementation TMLatestEpisodesTableViewDataSourceAndDelegate

- (instancetype)initWithDelegate:(id<TMSelectPodcastEpisodeDelegate>)delegate {
    self = [super init];
    
    if (self) {
        _delegate = delegate;
        _podcastsManager = [TMPodcastsManager new];
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
    
    cell.downloadDelegate = self;
    cell.episode = podcastEpisode;
    
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
        title = @"New";
    } else {
        title = @"Already Heard";
    }
    
    return title;
}

#pragma mark - TMPodcastEpisodeDownloadDelegate methods

- (void)startDownloadForEpisode:(id<TMPodcastEpisodeDelegate>)episode {

    NSString *fileName = [episode.downloadURLString lastPathComponent];
    [self.podcastsManager downloadPodcastEpisodeAtURL:episode.downloadURLString
                                         withFileName:fileName
                                          updateBlock:^(CGFloat downloadPercentage) {
                                              episode.downloadPercentage = downloadPercentage;
                                          }
                                         successBlock:^(NSString *filePath) {
                                             episode.fileLocation = filePath;
                                         } andFailureBlock:^(NSError *error) {
                                             NSLog(@"Error while downloading podcast: %@", error.debugDescription);
    }];
}

- (void)stopDownloadForEpisode:(id<TMPodcastEpisodeDelegate>)episode {
    [self.podcastsManager cancelDownloadForPodcastEpisode:episode];
}

- (void)deleteDownloadForEpisode:(id<TMPodcastEpisodeDelegate>)episode {
    [self.podcastsManager deletePodcastEpisode:episode];
}


@end
