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
#import "TMPodcast.h"
#import "TMPodcastEpisode.h"
#import "TMAudioPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

static NSString * const kEpisodeCellReuseIdentifier = @"EpisodeCell";
static NSString * const kAudioPlayerSegue = @"audioPlayerSegue";

@interface TMPodcastEpisodesTableViewController ()

@property (strong, nonatomic) TMPodcast *podcast;
@property (strong, nonatomic) TMPodcastsManager *podcastsManager;
@property (strong, nonatomic) NSIndexPath *downloadingIndex;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) TMPodcastEpisode *episodeToPlay;

@end

@implementation TMPodcastEpisodesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self retrieveEpisodes];
}

- (void)retrieveEpisodes {

    __weak TMPodcastEpisodesTableViewController *weakSelf = self;
    NSString *episodesURLString = @"http://feeds.feedburner.com/serialpodcast?fmt=xml";
    [self.podcastsManager podcastEpisodesAtURL:episodesURLString
                              withSuccessBlock:^(TMPodcast *podcast) {
                                  weakSelf.podcast = podcast;
                                  [weakSelf.tableView reloadData];
                              }
                               andFailureBlock:^(NSError *error) {
#warning TODO
                               }];

}

- (TMPodcastsManager *)podcastsManager {
    if (!_podcastsManager) {
        _podcastsManager = [[TMPodcastsManager alloc] init];
    }
    
    return _podcastsManager;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.podcast.episodes.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TMPodcastEpisodesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kEpisodeCellReuseIdentifier forIndexPath:indexPath];
    
    TMPodcastEpisode *episode = [self.podcast.episodes objectAtIndex:indexPath.row];
    cell.titleLabel.text = episode.title;
    
    NSInteger minutes = episode.duration / 60;
    cell.durationLabel.text = [NSString stringWithFormat:@"%ld min", (long)minutes];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM d, YYYY"];
    cell.publishDateLabel.text = [dateFormatter stringFromDate:episode.publishDate];

    cell.progressView.hidden = YES;
    
    return cell;
}

#pragma mark - TableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    //store the indexPath we're downloading
    self.downloadingIndex = indexPath;

    //reset the progress indicator
    TMPodcastEpisodesTableViewCell *cell = (TMPodcastEpisodesTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.progressView setProgress:0];
    cell.progressView.hidden = NO;
    
    //get the episode download link
    TMPodcastEpisode *episode = [self.podcast.episodes objectAtIndex:indexPath.row];
    
    if (episode.fileLocation != nil) {
        //TEMP: navigate to the audioPlayerVC
        self.episodeToPlay = episode;
        [self performSegueWithIdentifier:kAudioPlayerSegue sender:nil];
        
    } else {
        //download the podcast
        NSString *fileName = [episode.downloadURL lastPathComponent];

        __weak TMPodcastEpisodesTableViewController *weakSelf = self;
        [self.podcastsManager downloadPodcastEpisodeAtURL:episode.downloadURL
                                             withFileName:fileName
                                              updateBlock:^(CGFloat downloadPercentage) {
                                                  TMPodcastEpisodesTableViewCell *downloadingCell = (TMPodcastEpisodesTableViewCell *)[weakSelf.tableView cellForRowAtIndexPath:indexPath];

                                                  //update the progress indicator
                                                  [downloadingCell.progressView setProgress:downloadPercentage];
                                                  
                                              }
                                             successBlock:^(NSString *filePath) {
                                                 //store the file location
                                                 episode.fileLocation = filePath;
                                                 
                                                 //get rid of the downloadingIndex
                                                 weakSelf.downloadingIndex = nil;
                                             }
                                          andFailureBlock:^(NSError *error) {
                                              //do something else!
                                              
                                              weakSelf.downloadingIndex = nil;
                                          }];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:kAudioPlayerSegue]) {
        TMAudioPlayerViewController *vc = (TMAudioPlayerViewController *)[segue destinationViewController];
        vc.episode = self.episodeToPlay;
    }
}


@end
