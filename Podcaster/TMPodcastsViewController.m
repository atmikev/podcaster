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
#import "TMDownloadUtilities.h"
#import "TMLatestEpisodesTableViewDataSourceAndDelegate.h"
#import "TMSelectPodcastEpisodeProtocol.h"
#import "TMSelectPodcastProtocol.h"
#import "TMAllEpisodesTableViewDataSourceAndDelegate.h"
#import "NSManagedObject+EntityName.h"

static NSString * const kEpisodesViewControllerSegue = @"episodesViewControllerSegue";
static NSString * const kAudioPlayerViewControllerSegue = @"audioPlayerViewControllerSegue";
static CGFloat const kEpisodeButtonFontHeight = 14;

@interface TMPodcastsViewController () <NSFetchedResultsControllerDelegate, TMSelectPodcastDelegate, TMSelectPodcastEpisodeDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *latestEpisodeButton;
@property (weak, nonatomic) IBOutlet UIButton *allEpisodesButton;

@property (strong, nonatomic) TMLatestEpisodesTableViewDataSourceAndDelegate *latestEpisodesTableViewDataSourceAndDelegate;
@property (strong, nonatomic) TMAllEpisodesTableViewDataSourceAndDelegate *allEpisodesTableViewDataSourceAndDelegate;
@property (strong, nonatomic) TMPodcastsManager *podcastsManager;
@property (strong, nonatomic) NSMutableArray *imagesArray;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) id selectedItem;

- (IBAction)episodeButtonsHandler:(UIButton *)senderButton;

@end

@implementation TMPodcastsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //setup the data sources/delegates
    self.podcastsManager = [TMPodcastsManager new];
    self.latestEpisodesTableViewDataSourceAndDelegate = [[TMLatestEpisodesTableViewDataSourceAndDelegate alloc] initWithDelegate:self];
    self.allEpisodesTableViewDataSourceAndDelegate = [[TMAllEpisodesTableViewDataSourceAndDelegate alloc] initWithDelegate:self];
    
    //start out on the latestEpisodesTableViewDataSource
    [self setNewDataSource:self.latestEpisodesTableViewDataSourceAndDelegate andDelegate:self.latestEpisodesTableViewDataSourceAndDelegate];
    
    //poor form, come back to this
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
    
    self.title = @"My Podcasts";
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

- (void)updateButtonFontsWithSenderButton {
    //figure out which button should be bolded, and which shouldn't
    UIButton *otherButton = self.allEpisodesButton;
    UIButton *selectedButton = self.latestEpisodeButton;
    if (self.tableView.dataSource == self.allEpisodesTableViewDataSourceAndDelegate) {
        otherButton = self.latestEpisodeButton;
        selectedButton = self.allEpisodesButton;
    }
    
    //set the sender button to have a bold fond
    UIFont *regularFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:kEpisodeButtonFontHeight];
    UIFont *boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:kEpisodeButtonFontHeight];
    
    selectedButton.titleLabel.font = boldFont;
    otherButton.titleLabel.font = regularFont;
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
    [self setNewDataSource:newDataSourceAndDelegate andDelegate:newDataSourceAndDelegate];

}

- (void)setNewDataSource:(id<UITableViewDataSource>)datasource andDelegate:(id<UITableViewDelegate>)delegate {
    self.tableView.dataSource = datasource;
    self.tableView.delegate = delegate;
    
    [self.tableView reloadData];
    
    //update the episode button fonts
    [self updateButtonFontsWithSenderButton];
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


#pragma IBActions

- (IBAction)episodeButtonsHandler:(UIButton *)senderButton {
    
    //switch out the data source and reload
    [self switchDataSourcesAndDelegates];
}

#pragma TMSelectPodcastEpisodeProtocol methods

- (void)didSelectEpisode:(TMPodcastEpisode *)episode {
    self.selectedItem = episode;
    [self performSegueWithIdentifier:kAudioPlayerViewControllerSegue sender:self];
}

#pragma TMSelectPodcastProtocol methods

- (void)didSelectPodcast:(id<TMPodcastDelegate>)podcast {
    self.selectedItem = podcast;
    [self performSegueWithIdentifier:kEpisodesViewControllerSegue sender:self];
}


@end
