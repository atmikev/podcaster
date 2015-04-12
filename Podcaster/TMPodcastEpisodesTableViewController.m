//
//  TMPodcastEpisodesTableViewController.m
//  Podcaster
//
//  Created by Tyler Mikev on 3/7/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMPodcastEpisodesTableViewController.h"
#import "TMPodcastsManager.h"
#import "TMPodcastEpisodesTableViewCell.h"
#import "TMPodcastEpisodeHeaderTableViewCell.h"
#import "TMPodcast.h"
#import "TMPodcastEpisode.h"
#import "TMAudioPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

static NSString * const kEpisodeCellReuseIdentifier = @"EpisodeCell";
static NSString * const kEpisodeHeaderCellReuseIdentifier = @"EpisodeHeaderCell";
static NSString * const kAudioPlayerSegue = @"audioPlayerSegue";

@interface TMPodcastEpisodesTableViewController ()

@property (strong, nonatomic) TMPodcastsManager *podcastsManager;
@property (strong, nonatomic) NSIndexPath *downloadingIndex;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) TMPodcastEpisode *episodeToPlay;

@end

@implementation TMPodcastEpisodesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self findDownloadedEpisodes];
}


- (TMPodcastsManager *)podcastsManager {
    if (!_podcastsManager) {
        _podcastsManager = [[TMPodcastsManager alloc] init];
    }
    
    return _podcastsManager;
}

- (void)findDownloadedEpisodes {
    //populate any potentially downloaded podcast episodes with their file locations
    for (TMPodcastEpisode *episode in self.podcast.episodes) {
        NSString *fileLocation = [self.podcastsManager filePathForEpisode:episode];
        if (fileLocation) {
            episode.fileLocation = fileLocation;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger rows = 0;
    if (section == 0) {
        rows = 1;
    } else {
        rows = self.podcast.episodes.count;
    }
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cellToReturn = nil;
    
    if (indexPath.section == 0) {
        TMPodcastEpisodeHeaderTableViewCell *episodeHeaderCell = [tableView dequeueReusableCellWithIdentifier:kEpisodeHeaderCellReuseIdentifier forIndexPath:indexPath];
        [episodeHeaderCell setupCellWithPodcast:self.podcast];
        cellToReturn = episodeHeaderCell;
    } else {
        TMPodcastEpisodesTableViewCell *episodeCell = [tableView dequeueReusableCellWithIdentifier:kEpisodeCellReuseIdentifier forIndexPath:indexPath];
        TMPodcastEpisode *episode = [self.podcast.episodes objectAtIndex:indexPath.row];
        [episodeCell setupCellWithEpisode:episode];
        cellToReturn = episodeCell;
    }
    
    return cellToReturn;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if (indexPath.section == 0) {
        height = 120;
    } else {
        height = 92;
    }
    return height;
}

#pragma mark - TableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    //store the indexPath we're downloading
    self.downloadingIndex = indexPath;
    
    //get the episode download link
    TMPodcastEpisode *episode = [self.podcast.episodes objectAtIndex:indexPath.row];
    
//    if (episode.fileLocation != nil) {
    
        self.episodeToPlay = episode;
        [self performSegueWithIdentifier:kAudioPlayerSegue sender:nil];
        
//    } else {
//        
//        //reset the progress indicator
//        TMPodcastEpisodesTableViewCell *cell = (TMPodcastEpisodesTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
//        [cell.progressView setProgress:0];
//        cell.progressView.hidden = NO;
//        
//        //download the podcast
//        NSString *fileName = [episode.downloadURL lastPathComponent];
//        __weak TMPodcastEpisodesTableViewController *weakSelf = self;
//        [self.podcastsManager downloadPodcastEpisodeAtURL:episode.downloadURL
//                                             withFileName:fileName
//                                              updateBlock:^(CGFloat downloadPercentage) {
//                                                  TMPodcastEpisodesTableViewCell *downloadingCell = (TMPodcastEpisodesTableViewCell *)[weakSelf.tableView cellForRowAtIndexPath:indexPath];
//
//                                                  //update the progress indicator
//                                                  [downloadingCell.progressView setProgress:downloadPercentage];
//                                                  
//                                              }
//                                             successBlock:^(NSString *filePath) {
//                                                 //store the file location
//                                                 episode.fileLocation = filePath;
//                                                 
//                                                 //update the cell to show we're done downloading
//                                                 [weakSelf.tableView reloadRowsAtIndexPaths:@[weakSelf.downloadingIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
//                                                 
//                                                 //get rid of the downloadingIndex
//                                                 weakSelf.downloadingIndex = nil;
//                                             }
//                                          andFailureBlock:^(NSError *error) {
//#warning Handle this error
//                                              weakSelf.downloadingIndex = nil;
//                                          }];
//    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:kAudioPlayerSegue]) {
        TMAudioPlayerViewController *vc = (TMAudioPlayerViewController *)[segue destinationViewController];
        vc.episode = self.episodeToPlay;
        vc.podcastImage = self.podcast.podcastImage;
    }
}


@end
