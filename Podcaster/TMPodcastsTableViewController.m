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
#import "TMSubscribedPodcast.h"
#import "AppDelegate.h"
#import "TMDownloadManager.h"

static NSString * const kEpisodesViewControllerSegue = @"episodesViewControllerSegue";

@interface TMPodcastsTableViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) TMSearchResultsTableViewController *searchResultsController;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSArray *podcastsArray;
@property (strong, nonatomic) TMPodcastsManager *podcastsManager;
@property (strong, nonatomic) NSMutableArray *imagesArray;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) id<TMPodcastDelegate> selectedPodcast;

@end

@implementation TMPodcastsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.podcastsManager = [TMPodcastsManager new];
        
    [self setupSearchController];
    
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
    } else {
        self.podcastsArray = [[self fetchedResultsController] fetchedObjects];
    }
    
    [self.tableView reloadData];
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
                                        managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:@"Root"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id  sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TMPodcastTableViewCell *cell = (TMPodcastTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kPodcastCellReuseIdentifier forIndexPath:indexPath];
    
    TMSubscribedPodcast *subscribedPodcast = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.titleLabel.text = subscribedPodcast.title;
    
    if (subscribedPodcast.podcastImage) {
        cell.podcastImageView.image = subscribedPodcast.podcastImage;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (self.tableView == tableView) {
        self.selectedPodcast = (id<TMPodcastDelegate>)[self.podcastsArray objectAtIndex:indexPath.row];
    } else if (self.searchResultsController.tableView == tableView) {
        self.selectedPodcast = (id<TMPodcastDelegate>)[self.searchResultsController.podcastsArray objectAtIndex:indexPath.row];
    }

    [self performSegueWithIdentifier:kEpisodesViewControllerSegue sender:self];
}

#pragma mark - Table view delegates

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

#pragma mark - Segue stuff

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kEpisodesViewControllerSegue]) {
        TMPodcastEpisodesTableViewController *vc = (TMPodcastEpisodesTableViewController *)segue.destinationViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.podcast = self.selectedPodcast;
        self.selectedPodcast = nil;
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
