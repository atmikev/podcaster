//
//  TMPodcastsTableViewController.m
//  Podcaster
//
//  Created by Tyler Mikev on 3/13/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMPodcastsViewController.h"
#import "TMPodcastsManager.h"
#import "TMPodcastTableViewCell.h"
#import "TMPodcast.h"
#import "TMPodcastEpisode.h"
#import "TMPodcastEpisodesTableViewController.h"
#import "TMAudioPlayerViewController.h"
#import "TMSearchResultsTableViewController.h"
#import "TMSubscribedPodcast.h"
#import "TMSubscribedEpisode.h"
#import "AppDelegate.h"
#import "TMDownloadManager.h"
#import "TMLatestEpisodesTableViewDataSourceAndDelegate.h"
#import "TMSelectPodcastProtocol.h"
#import "TMSelectPodcastEpisodeProtocol.h"
#import "TMAllEpisodesTableViewDataSourceAndDelegate.h"
#import "NSManagedObject+EntityName.h"


static NSString * const kEpisodesViewControllerSegue = @"episodesViewControllerSegue";
static NSString * const kAudioPlayerViewControllerSegue = @"audioPlayerViewControllerSegue";

@interface TMPodcastsViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, NSFetchedResultsControllerDelegate, TMSelectPodcastDelegate, TMSelectPodcastEpisodeDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *episodesSegmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) TMSearchResultsTableViewController *searchResultsController;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) TMLatestEpisodesTableViewDataSourceAndDelegate *latestEpisodesTableViewDataSourceAndDelegate;
@property (strong, nonatomic) TMAllEpisodesTableViewDataSourceAndDelegate *allEpisodesTableViewDataSourceAndDelegate;
@property (strong, nonatomic) TMPodcastsManager *podcastsManager;
@property (strong, nonatomic) NSMutableArray *imagesArray;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

//ATM: UGH FIX THIS TOO
@property (strong, nonatomic) id selectedItem;

- (IBAction)episodesSegmentedControlHandler:(id)sender;

@end

@implementation TMPodcastsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //setup the data sources/delegates
    self.podcastsManager = [TMPodcastsManager new];
    self.latestEpisodesTableViewDataSourceAndDelegate = [[TMLatestEpisodesTableViewDataSourceAndDelegate alloc] initWithDelegate:self];
    self.allEpisodesTableViewDataSourceAndDelegate = [[TMAllEpisodesTableViewDataSourceAndDelegate alloc] initWithDelegate:self];
    
    [self setupSearchController];
    
    //start out on the latestEpisodesTableViewDataSource
    self.tableView.dataSource = self.latestEpisodesTableViewDataSourceAndDelegate;
    self.tableView.delegate = self.latestEpisodesTableViewDataSourceAndDelegate;
    
    //poor form, come back to this
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //fetch any subscribed podcasts
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Fetching error %@, %@", error, [error userInfo]);
    }
    
    //get the latest episode for each podcast
    NSArray *subscribedPodcastsArray = [[self fetchedResultsController] fetchedObjects];
    
    //give the subscribedPodcastsArray to our allEpisodesTableViewDataSource
    self.allEpisodesTableViewDataSourceAndDelegate.subscribedPodcasts = subscribedPodcastsArray;
    
    //retrieve the latest episodes for our subscribed podcasts
    [self retrieveLatestEpisodesForPodcastsArray:subscribedPodcastsArray];
    
}

- (void)retrieveLatestEpisodesForPodcastsArray:(NSArray *)subscribedPodcastsArray {
    
    __block NSInteger finishedCalls = 0;
    for (TMSubscribedPodcast *subscribedPodcast in subscribedPodcastsArray) {
        [self.podcastsManager podcastEpisodesAtURL:subscribedPodcast.feedURLString withSuccessBlock:^(TMPodcast *podcast) {
            //increment the retrievedCount
            finishedCalls++;
            
            subscribedPodcast.episodes = podcast.episodes;
            
            if (finishedCalls == subscribedPodcastsArray.count) {
                [self handleRetrievedEpisodes:subscribedPodcastsArray];
            }
        } andFailureBlock:^(NSError *error) {
            NSLog(@"Error getting episodes for subscribed podcasts: %@", error.localizedDescription);
            
            finishedCalls++;
            
            //increment the retrievedCount
            if (finishedCalls == subscribedPodcastsArray.count) {
                [self handleRetrievedEpisodes:subscribedPodcastsArray];
            }
        }];
    }
}

- (void)handleRetrievedEpisodes:(NSArray *)subscribedPodcastsArray{
    //sort the data by latest podcast episode in descending order
    NSMutableArray *latestEpisodes = [NSMutableArray new];
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"publishDate" ascending:NO];
    for (TMSubscribedPodcast *subscribedPodcast in subscribedPodcastsArray) {
        TMPodcastEpisode *latestEpisode = [subscribedPodcast.episodes sortedArrayUsingDescriptors:@[dateDescriptor]].firstObject;
        TMSubscribedEpisode *subscribedEpisode = [TMSubscribedEpisode instanceFromTMPodcastEpisode:latestEpisode inContext:self.managedObjectContext];
        
        [latestEpisodes addObject:subscribedEpisode];
    }
    
    //give the podcast episodes to our latest episode data source
    self.latestEpisodesTableViewDataSourceAndDelegate.subscribedEpisodesArray = latestEpisodes;
    
    //reload the data
    [self.tableView reloadData];
}

- (void)setupSearchController {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];

    self.searchResultsController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([TMSearchResultsTableViewController class])];
    self.searchResultsController.delegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    
    // Search is now just presenting a view controller. As such, normal view controller
    // presentation semantics apply. Namely that presentation will walk up the view controller
    // hierarchy until it finds the root view controller or one that defines a presentation context.
    //
    self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:[TMSubscribedPodcast entityName] inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"title" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:@"Root"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

- (void)switchDataSourcesAndDelegates {
    
    id newDataSourceAndDelegate = nil;
    
    //figure out which datasource and delegate we should switch to
    if (self.tableView.dataSource == self.latestEpisodesTableViewDataSourceAndDelegate) {
        newDataSourceAndDelegate = self.allEpisodesTableViewDataSourceAndDelegate;
    } else {
        newDataSourceAndDelegate = self.latestEpisodesTableViewDataSourceAndDelegate;
    }
    
    //set the new datasource and delegate
    self.tableView.dataSource = (id<UITableViewDataSource>)newDataSourceAndDelegate;
    self.tableView.delegate = (id<UITableViewDelegate>)newDataSourceAndDelegate;
    
    [self.tableView reloadData];
}

#pragma mark - Segue stuff

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kEpisodesViewControllerSegue]) {
        TMPodcastEpisodesTableViewController *vc = (TMPodcastEpisodesTableViewController *)segue.destinationViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.podcast = (id<TMPodcastDelegate>) self.selectedItem;
    } else if ([segue.identifier isEqualToString:kAudioPlayerViewControllerSegue]) {
        TMAudioPlayerViewController *vc = (TMAudioPlayerViewController *)segue.destinationViewController;
        vc.episode = (TMPodcastEpisode *)self.selectedItem;
        vc.podcastImage = vc.episode.podcast.podcastImage;
        vc.managedObjectContext = self.managedObjectContext;
    }

    self.selectedItem = nil;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    
    // strip out all the leading and trailing spaces
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (strippedString) {
        __weak TMPodcastsViewController *weakSelf = self;
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

#pragma IBActions

- (void)episodesSegmentedControlHandler:(id)sender {
    
    //switch out the data source and reload
    [self switchDataSourcesAndDelegates];
}

#pragma TMSelectPodcastProtocol methods

- (void)didSelectPodcast:(id<TMPodcastDelegate>)podcast {
    self.selectedItem = podcast;
    [self performSegueWithIdentifier:kEpisodesViewControllerSegue sender:self];
}

#pragma TMSelectPodcastEpisodeProtocol methods

- (void)didSelectEpisode:(TMPodcastEpisode *)episode {
    self.selectedItem = episode;
    [self performSegueWithIdentifier:kAudioPlayerViewControllerSegue sender:self];
}


@end
