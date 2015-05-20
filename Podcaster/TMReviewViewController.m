//
//  TMReviewViewController.m
//  Podcaster
//
//  Created by Tyler Mikev on 5/18/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMReviewViewController.h"
#import "HCSStarRatingView.h"

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
}

- (void)submitReview {
    //dismiss the keyboard
    [self.view endEditing:YES];
    
    //do the submission stuff
    
    //pop the vc
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Button Handlers

- (IBAction)submitButtonHandler:(id)sender {
    [self submitReview];
}

@end
