//
//  TMSearchResultsTableViewController.m
//  Podcaster
//
//  Created by Tyler Mikev on 4/12/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMSearchResultsTableViewController.h"

#import "TMPodcast.h"
#import "TMPodcastTableViewCell.h"
#import "TMDownloadManager.h"
#import "TMSelectPodcastProtocol.h"

@implementation TMSearchResultsTableViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.podcastsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   TMPodcastTableViewCell *cell = (TMPodcastTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kPodcastCellReuseIdentifier forIndexPath:indexPath];
    
    TMPodcast *podcast = [self.podcastsArray objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = podcast.title;
    
    if (podcast.podcastImage) {
        cell.podcastImageView.image = podcast.podcastImage;
    } else {
        [TMDownloadManager downloadImageForPodcast:podcast
                                           forCell:cell
                                       atIndexPath:indexPath
                                       inTableView:tableView];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TMPodcast *podcast = [self.podcastsArray objectAtIndex:indexPath.row];
    [self.delegate didSelectPodcast:podcast];
    
}

@end
