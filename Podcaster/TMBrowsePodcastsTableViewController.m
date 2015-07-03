//
//  TMBrowsePodcastsTableViewController.m
//  Podcaster
//
//  Created by Tyler Mikev on 6/13/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMBrowsePodcastsTableViewController.h"
#import "AppDelegate.h"
#import "TMBrowsePodcastsCell.h"
#import "TMBrowsePopularPodcastCell.h"
#import "TMPodcast.h"
#import "TMBrowsePodcastsManager.h"
#import "TMGenre.h"
#import "TMDownloadManager.h"
#import "TMPodcastsManager.h"
#import "TMBrowsePodcastButton.h"
#import "TMPodcastEpisodesTableViewController.h"

static NSString * const kPodcastEpisodesSegue = @"browseToEpisodeSegue";

@interface TMBrowsePodcastsTableViewController ()

@property (strong, nonatomic) TMBrowsePodcastsManager *browseManager;
@property (strong, nonatomic) NSMutableArray *genresMutableArray;
@property (assign, nonatomic) NSInteger totalGenresCount;
@property (strong, nonatomic) TMGenre *popularGenre;
@property (strong, nonatomic) TMPodcast *selectedPodcast;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation TMBrowsePodcastsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //poor form again, come back to this
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
    
    self.browseManager = [TMBrowsePodcastsManager new];
    self.genresMutableArray = [NSMutableArray new];
    
    [self retrieveGenres];
    
    self.title = @"Search";
}

- (void)retrieveGenres {

    [self.browseManager retrieveGenresDictionaryWithSuccessBlock:^(NSArray *genresArray) {
        
        self.totalGenresCount = genresArray.count;
        
        //order the array by genre name
        NSSortDescriptor *sortDescriptior = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        NSMutableArray *orderedMutableArray = [[genresArray sortedArrayUsingDescriptors:@[sortDescriptior]] mutableCopy];
        
        //create the popular array and insert it in the first spot to make sure its up top
        //create a fake genre to work with the rest of the code
        self.popularGenre = [TMGenre new];
        self.popularGenre.name = @"Popular";
        
        [orderedMutableArray insertObject:self.popularGenre atIndex:0];
        self.genresMutableArray = orderedMutableArray;
        
        [self reloadDataOnMainThread];
        
        //get all the podcasts
        for (TMGenre *genre in self.genresMutableArray) {
            [self retrievePodcastsForGenre:genre];
        }
        
    } andFailureBlock:^(NSError *error) {
        NSLog(@"Error getting genres:%@", error.debugDescription);
    }];
}

- (void)retrievePodcastsForGenre:(TMGenre *)genre {
    [self.browseManager retrieveTopPodcastsForGenre:genre withSuccessBlock:^(NSArray *podcastsArray) {
        
        //store the podcasts on the genre
        genre.podcasts = podcastsArray;
        
        //refresh the table on the main thread
        [self reloadDataOnMainThread];
        
    } andFailureBlock:^(NSError *error) {
        NSLog(@"Error getting top genre podcasts:%@", error.debugDescription);
    }];
}

- (void)setupBrowsePocastsCell:(TMBrowsePodcastsCell *)cell withGenre:(TMGenre *)genre {
    //remove all the existing subviews in the scrollview
    for (UIView *view in [cell.scrollView subviews]) {
        [view removeFromSuperview];
    }
    
    //set the title
    cell.titleLabel.text = genre.name;

    //add the new images
    NSInteger x = 0;
    for (TMPodcast *podcast in genre.podcasts) {
        
        //fit scrollview's height
        NSInteger side = cell.scrollView.frame.size.height;
       
        //make the button
        TMBrowsePodcastButton *button = [[TMBrowsePodcastButton alloc] initWithFrame:CGRectMake(x, 0, side, side)];
        button.imageView.contentMode = UIViewContentModeScaleAspectFill;

        //store the podcast on the button so when its tapped we know where to navigate to
        button.podcast = podcast;

        //add the button handler
        [button addTarget:self action:@selector(podcastButtonHandler:) forControlEvents:UIControlEventTouchUpInside];

        if (podcast.podcastImage) {
            [button setBackgroundImage:podcast.podcastImage forState:UIControlStateNormal];
        }
        
        [cell.scrollView addSubview:button];
        x += side;
    }
    
    NSInteger width = x;
    cell.scrollView.contentSize = CGSizeMake(width, 0);
}

- (void)podcastButtonHandler:(id)sender {
    TMBrowsePodcastButton *button = (TMBrowsePodcastButton *)sender;
    //maybe sender IS meant to handle this sort of stuff?
    [self performSegueWithIdentifier:kPodcastEpisodesSegue sender:button];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kPodcastEpisodesSegue]) {
        TMPodcastEpisodesTableViewController *vc = segue.destinationViewController;
        TMBrowsePodcastButton *button = (TMBrowsePodcastButton *)sender;
        vc.podcast = button.podcast;
        vc.managedObjectContext = self.managedObjectContext;
    }
}

- (void)reloadDataOnMainThread {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.genresMutableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    //not happy with this implementation at all, but its been a long day and I need to keep moving
    TMBrowsePodcastsCell *cellToReturn = nil;

    if (indexPath.row == 0) {
        //popular podcasts row
        TMBrowsePopularPodcastCell *cell = (TMBrowsePopularPodcastCell *)[tableView dequeueReusableCellWithIdentifier:kTMBrowsePopularPodcastsCellIdentifier forIndexPath:indexPath];
        cellToReturn = cell;
    } else {
        TMBrowsePodcastsCell *cell = (TMBrowsePodcastsCell *)[tableView dequeueReusableCellWithIdentifier:kTMBrowsePodcastsCellIdentifier forIndexPath:indexPath];
        cellToReturn = cell;
    }
    
    TMGenre *genre = [self.genresMutableArray objectAtIndex:indexPath.row];
    [self setupBrowsePocastsCell:cellToReturn withGenre:genre];

    return cellToReturn;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 0 ? 208 : 138;
}

@end
