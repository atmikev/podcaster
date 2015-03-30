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

static NSString * const kPodcastCellReuseIdentifier = @"podcastCell";

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.podcastsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TMPodcastTableViewCell *cell = (TMPodcastTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kPodcastCellReuseIdentifier forIndexPath:indexPath];
    
    
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
