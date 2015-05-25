//
//  TMReviewViewController.m
//  Podcaster
//
//  Created by Tyler Mikev on 5/18/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMReviewViewController.h"
#import "HCSStarRatingView.h"
#import "TMRating.h"
#import <Parse/Parse.h>
#import "TMPodcastEpisode.h"
#import "TMPodcastProtocol.h"

@interface TMReviewViewController ()

@property (strong, nonatomic) HCSStarRatingView *ratingView;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UITextView *commentsTextView;

@end


@implementation TMReviewViewController

- (void)viewDidLoad {
    //setup rating view
    CGRect ratingViewRect = CGRectMake(20, 60, 340, 40);
    self.ratingView = [[HCSStarRatingView alloc] initWithFrame:ratingViewRect];
    [self.view addSubview:self.ratingView];
    
    //pop up the keyboard
    [self.commentsTextView becomeFirstResponder];
    
    //track page name and associated info
    [PFAnalytics trackEvent:@"startedReview" dimensions:[self dimensions]];
}

- (void)submitReview {
    //track that we've submitted the review
    [PFAnalytics trackEvent:@"finishedReview" dimensions:[self dimensions]];
    
    //dismiss the keyboard
    [self.view endEditing:YES];
    
    //do the submission stuff
    TMRating *rating = [TMRating object];
    rating.score = self.ratingView.value;
    rating.comment = self.commentsTextView.text;
    rating.episode = self.episode.title;
    rating.podcast = self.episode.podcast.title;
    rating.initiatedByUser = self.initiatedByUser;
    rating.user = [PFUser currentUser];
    [rating saveInBackgroundWithBlock:^(BOOL succeeded, NSError *PF_NULLABLE_S error){
        if (!succeeded) {
            [[[UIAlertView alloc] initWithTitle:@"Uh oh" message:@"There was an error saving your rating. Sorry we blew it. Please try again!!!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }];
    
    //pop the vc
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSDictionary *)dimensions {
    
    NSString *initiatedByUserString = self.initiatedByUser ? @"Yes" : @"No";
    NSDictionary *dimensions = @{@"episode" : self.episode.title,
                                 @"podcast" : self.episode.podcast.title,
                                 @"episodeTime" : [NSString stringWithFormat:@"%f", self.episodeTime],
                                 @"initiatedByUser" : initiatedByUserString};
    
    return dimensions;
}

#pragma mark - Button Handlers

- (IBAction)submitButtonHandler:(id)sender {
    [self submitReview];
}

@end
