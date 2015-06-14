//
//  TMBrowsePodcastsTableViewController.m
//  Podcaster
//
//  Created by Tyler Mikev on 6/13/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMBrowsePodcastsTableViewController.h"
#import "TMBrowsePodcastsCell.h"
#import "TMPodcast.h"
#import "TMBrowsePodcastsManager.h"
#import "TMGenre.h"
#import "TMDownloadManager.h"
#import "TMPodcastsManager.h"

static const NSInteger kImageViewSide = 100;

@interface TMBrowsePodcastsTableViewController ()

@property (strong, nonatomic) TMBrowsePodcastsManager *browseManager;
@property (strong, nonatomic) NSMutableArray *genresMutableArray;

@end

@implementation TMBrowsePodcastsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.browseManager = [TMBrowsePodcastsManager new];
    self.genresMutableArray = [NSMutableArray new];
    
    [self retrieveGenres];
}

- (void)retrieveGenres {
    [self.browseManager retrieveGenresDictionaryWithSuccessBlock:^(NSArray *genresArray) {
        
        //get all the podcasts
        for (TMGenre *genre in genresArray) {
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
        [self.genresMutableArray addObject:genre];
        
        //refresh the table
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    } andFailureBlock:^(NSError *error) {
        NSLog(@"Error getting top podcasts:%@", error.debugDescription);
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
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, kImageViewSide, kImageViewSide)];
        
        if (podcast.podcastImage == nil) {
            //download the image
            [TMDownloadManager downloadImageAtURL:podcast.imageURL withCompletionBlock:^(UIImage *image) {
                podcast.podcastImage = image;
                imageView.image = podcast.podcastImage;
            }];
        } else {
            imageView.image = podcast.podcastImage;
        }
        
        [cell.scrollView addSubview:imageView];
        x += kImageViewSide;
    }
    
    NSInteger width = x;
    cell.scrollView.contentSize = CGSizeMake(width, 0);
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

    TMBrowsePodcastsCell *cell = (TMBrowsePodcastsCell *)[tableView dequeueReusableCellWithIdentifier:kTMBrowsePodcastsCellIdentifier forIndexPath:indexPath];
    
    TMGenre *genre = [self.genresMutableArray objectAtIndex:indexPath.row];
    [self setupBrowsePocastsCell:cell withGenre:genre];

    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 138;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

@end
