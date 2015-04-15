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
#import "TMSearchResultsTableViewController.h"

static NSString * const kEpisodesViewControllerSegue = @"episodesViewControllerSegue";

@interface TMPodcastsTableViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) TMSearchResultsTableViewController *searchResultsController;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSArray *podcastsArray;
@property (strong, nonatomic) TMPodcastsManager *podcastsManager;
@property (strong, nonatomic) NSMutableArray *imagesArray;

@end

@implementation TMPodcastsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.podcastsManager = [TMPodcastsManager new];
    
    //unecessary for the demo
//    [self setupSearchController];
    
    [self createDemoPodcast];
}

- (void)createDemoPodcast {
    TMPodcast *podcast = [TMPodcast new];
    podcast.title = @"Reply All";
    podcast.imageURL = [NSURL URLWithString:@"http://is1.mzstatic.com/image/pf/us/r30/Podcasts3/v4/cc/3f/13/cc3f13c2-e218-a50c-5999-1dc01c6920e4/mza_107882299047792687.60x60-50.jpg"];
    podcast.linkURL = [NSURL URLWithString:@"http://www.replyall.limo"];
    
    self.podcastsArray = @[podcast];
}

- (void)setupSearchController {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];

    self.searchResultsController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([TMSearchResultsTableViewController class])];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
    self.searchResultsController.tableView.delegate = self;
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    
    self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed
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
    
    if (podcast.podcastImage) {
        cell.podcastImageView.image = podcast.podcastImage;
    } else {
        [TMPodcastsManager downloadImageForPodcast:podcast
                                           forCell:cell
                                       atIndexPath:indexPath
                                       inTableView:tableView];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TMPodcast *podcast = nil;
    
    if (self.tableView == tableView) {
        podcast = [self.podcastsArray objectAtIndex:indexPath.row];
    } else if (self.searchResultsController.tableView == tableView) {
        podcast = [self.searchResultsController.podcastsArray objectAtIndex:indexPath.row];
    }
    
    [self performSegueWithIdentifier:kEpisodesViewControllerSegue sender:podcast];
}

#pragma mark - Table view delegates

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

#pragma mark - Segue stuff

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //ugh, seriously, figure out a better way to pass the podcast...
    TMPodcast *podcast = (TMPodcast *)sender;
    
    if ([segue.identifier isEqualToString:kEpisodesViewControllerSegue]) {
        TMPodcastEpisodesTableViewController *vc = (TMPodcastEpisodesTableViewController *)segue.destinationViewController;
        vc.podcast = podcast;
    }
    
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    
    // strip out all the leading and trailing spaces
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (strippedString) {
        __weak TMPodcastsTableViewController *weakSelf = self;
        [self.podcastsManager searchForPodcastsWithSearchString:strippedString
                                                     maxResults:25
                                                   successBlock:^(NSArray *podcasts) {
                                                       weakSelf.searchResultsController.podcastsArray = podcasts;
                                                       
                                                       //UI stuff needs to be done on the main thread, you idiot.
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           [weakSelf.searchResultsController.tableView reloadData];
                                                       });
                                                   } andFailureBlock:^(NSError *error) {
#warning Handle error
                                                   }];
    }
    
}


@end
