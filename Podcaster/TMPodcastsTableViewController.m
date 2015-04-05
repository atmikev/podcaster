//
//  TMPodcastsTableViewController.m
//  Podcaster
//
//  Created by Tyler Mikev on 3/13/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMPodcastsTableViewController.h"
#import "TMPodcastsManager.h"
#import "TMPodcastTableViewCell.h"
#import "TMPodcast.h"
#import "TMPodcastEpisodesTableViewController.h"

static NSString * const kPodcastCellReuseIdentifier = @"podcastCell";
static NSString * const kEpisodesViewControllerSegue = @"episodesViewControllerSegue";

@interface TMPodcastsTableViewController ()

@property (strong, nonatomic) NSArray *podcastsArray;
@property (strong, nonatomic) TMPodcastsManager *podcastsManager;
@property (strong, nonatomic) NSMutableArray *imagesArray;

@end

@implementation TMPodcastsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.podcastsManager = [TMPodcastsManager new];
    
    __weak TMPodcastsTableViewController *weakSelf = self;
    [self.podcastsManager topPodcastsWithSuccessBlock:^(NSArray *podcasts) {
        weakSelf.podcastsArray = podcasts;
        [weakSelf.tableView reloadData];
    } andFailureBlock:^(NSError *error) {
#warning TODO
    }];
    
}

- (void)downloadImageForPodcast:(TMPodcast *)podcast forCell:(UITableViewCell *)originalCell atIndexPath:(NSIndexPath *)indexPath {

    __weak TMPodcastsTableViewController *weakSelf = self;
    //download the image
    [[[NSURLSession sharedSession] dataTaskWithURL:podcast.imageURL
                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                    if (error) {
#warning Handle this error
                                        NSLog(@"Error loading podcast image: %@", error.debugDescription);
                                    } else if (data) {
                                        UIImage *image = [UIImage imageWithData:data];
                                        podcast.podcastImage = image;
                                        
                                        TMPodcastTableViewCell *cell = (TMPodcastTableViewCell *)[weakSelf.tableView cellForRowAtIndexPath:indexPath];
                                        if (cell == originalCell) {
                                            cell.podcastImageView.image = image;
                                        }
                                    }
                                }] resume];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.podcastsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TMPodcastTableViewCell *cell = (TMPodcastTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kPodcastCellReuseIdentifier forIndexPath:indexPath];
    
    TMPodcast *podcast = [self.podcastsArray objectAtIndex:indexPath.row];
    [self downloadImageForPodcast:podcast forCell:cell atIndexPath:indexPath];
    cell.titleLabel.text = podcast.title;
    if (podcast.podcastImage != nil) {
        cell.podcastImageView.image = podcast.podcastImage;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    TMPodcast *podcast = [self.podcastsArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:kEpisodesViewControllerSegue sender:podcast];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //ugh, seriously, figure out a better way to pass the podcast...
    TMPodcast *podcast = (TMPodcast *)sender;
    
    if ([segue.identifier isEqualToString:kEpisodesViewControllerSegue]) {
        TMPodcastEpisodesTableViewController *vc = (TMPodcastEpisodesTableViewController *)segue.destinationViewController;
        vc.podcast = podcast;
    }
    
}

@end
