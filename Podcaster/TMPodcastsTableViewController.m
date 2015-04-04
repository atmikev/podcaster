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
    
    cell.titleLabel.text = podcast.title;
    
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
