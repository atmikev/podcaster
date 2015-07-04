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

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

static NSString * const kCommentTextViewDefaultText = @"What did you think?";

@interface TMReviewViewController ()<UITextViewDelegate>

@property (strong, nonatomic) HCSStarRatingView *ratingView;

@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UITextView *commentsTextView;
@property (weak, nonatomic) IBOutlet UIImageView *podcastImageView;
@property (weak, nonatomic) IBOutlet UILabel *podcastTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *episodeTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *seperatorView;

@end


@implementation TMReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //setup rating view
    [self setupRatingView];
    
    //setup episode section
    self.podcastImageView.image = self.episode.podcast.podcastImage;
    self.episodeTitleLabel.text = self.episode.title;
    self.podcastTitleLabel.text = self.episode.podcast.title;
    
    //setup the textView delegate and show the keyboard
    self.commentsTextView.delegate = self;
    
    //track page name and associated info
    [PFAnalytics trackEvent:@"startedReview" dimensions:[self dimensions]];

}

- (void)updateViewConstraints {
    
    [super updateViewConstraints];
    
    NSDictionary *metrics = @{@"margin":@8};
    NSDictionary *views = @{@"ratingView":self.ratingView,
                            @"imageView":self.podcastImageView,
                            @"seperatorView":self.seperatorView,
                            @"podcastLabel":self.podcastTitleLabel};
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView]-margin-[ratingView]-margin-|" options:0 metrics:metrics views:views];
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[podcastLabel]-margin-[ratingView]-margin-[seperatorView]" options:0 metrics:metrics views:views];
    
    [self.view addConstraints:horizontalConstraints];
    [self.view addConstraints:verticalConstraints];
}

- (void)setupRatingView {
    self.ratingView = [[HCSStarRatingView alloc] init];
    [self.ratingView setMaximumValue:5];
    [self.ratingView setMinimumValue:0];
    [self.ratingView setValue:0];
    
    self.ratingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.ratingView];
    
    [self.view setNeedsUpdateConstraints];
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
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - UITextViewDelegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (textView == self.commentsTextView && [textView.text isEqualToString:kCommentTextViewDefaultText]) {
        textView.text = @"";
    }
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (textView == self.commentsTextView && [textView.text isEqualToString:@""]) {
        textView.text = kCommentTextViewDefaultText;
    }
    
    return YES;
}

@end
