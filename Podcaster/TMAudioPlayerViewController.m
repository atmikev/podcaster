//
//  TMAudioPlayerViewController.m
//  Podcaster
//
//  Created by Tyler Mikev on 3/10/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMAudioPlayerViewController.h"
#import "TMAudioPlayerManager.h"
#import "TMNavigationController.h"
#import "TMReviewViewController.h"
#import "TMPodcastProtocol.h"
#import <Parse/Parse.h>

static NSString * const kPlayImageString = @"play";
static NSString * const kPauseImageString = @"pause";
static NSString * const kIsPlayingString = @"isPlaying";
static NSString * const kReviewViewControllerSegueString = @"reviewViewControllerSegue";

@interface TMAudioPlayerViewController () <TMAudioPlayerManagerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) TMAudioPlayerManager *audioPlayerManager;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) TMNavigationController *navController;
@property (assign, nonatomic) BOOL initiatedByUser;

@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIImageView *podcastImageView;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;
@property (weak, nonatomic) IBOutlet UILabel *timeElapsedLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeTotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *rateButton;

- (IBAction)playPause:(id)sender;
- (IBAction)timeSliderValueChanged:(id)sender;
- (IBAction)seekBackHandler:(id)sender;
- (IBAction)seekForwardHandler:(id)sender;

@end

@implementation TMAudioPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAudioPlayerManager];
    
    [self setupSeekSlider];
    
    //show the duration of the episode
    self.timeTotalLabel.text = [self.audioPlayerManager fileDurationString];
    
    //show podcast image
    self.podcastImageView.image = self.podcastImage;
    
    //set episode title
    self.titleLabel.text = self.episode.title;
    
    //store the custom navigation controller
    self.navController = (TMNavigationController *)self.navigationController;
    
    //start the episode
    [self playAudio];
    
    //workaround for ios 8 bug to prevent accidentally swiping back when trying to use the time bar
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //kvo on isPlaying for the play/pause image
    [self.audioPlayerManager addObserver:self
                              forKeyPath:kIsPlayingString
                                 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                 context:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    //remove observations
    [self.audioPlayerManager removeObserver:self forKeyPath:kIsPlayingString];
}

- (void)setupAudioPlayerManager {
    self.audioPlayerManager = [TMAudioPlayerManager sharedInstance];
    self.audioPlayerManager.delegate = self;
    self.audioPlayerManager.episode = self.episode;
    
}

- (void)setupSeekSlider {
    self.timeSlider.value = 0;
}

- (void)changePlayPauseButtonImage:(BOOL)isPlaying {
    NSString *imageName = isPlaying ? kPauseImageString : kPlayImageString;
    [self.playPauseButton setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)pauseAudio {
    [self.audioPlayerManager pause];
    [self changePlayPauseButtonImage:NO];
}

- (void)playAudio {
    [self.audioPlayerManager play];
    [self changePlayPauseButtonImage:YES];
    self.navController.currentAudioPlayerViewController = self;
}

- (void)showReviewVC:(BOOL)initiatedByUser {

    //track who initiated the review
    self.initiatedByUser = initiatedByUser;
    [self performSegueWithIdentifier:kReviewViewControllerSegueString sender:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if([keyPath isEqualToString:kIsPlayingString]) {
        BOOL isPlaying = [(NSNumber *)[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        [self changePlayPauseButtonImage:isPlaying];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:kReviewViewControllerSegueString]) {
        TMReviewViewController *reviewVC = [segue destinationViewController];
        reviewVC.initiatedByUser = self.initiatedByUser;
        reviewVC.episode = self.episode;
    }
    
}

#pragma mark - IBActions

- (IBAction)playPause:(id)sender {
    if (self.audioPlayerManager.isPlaying) {
        [self pauseAudio];
    } else {
        [self playAudio];
    }
    
}

- (IBAction)timerStartedSliding:(id)sender {
    //stop the audioplayer so the slider doesn't jerk around
    [self.audioPlayerManager pause];
}

- (IBAction)timeSliderValueChanged:(id)sender {
    [self.audioPlayerManager seekToPosition:self.timeSlider.value andPlay:YES];
}

- (IBAction)seekBackHandler:(id)sender {
    [self.audioPlayerManager seekWithInterval:-15];
}

- (IBAction)seekForwardHandler:(id)sender {
    [self.audioPlayerManager seekWithInterval:15];
}

- (IBAction)rateButtonHandler:(id)sender {
    [self showReviewVC:YES];
}

#pragma mark - Gesture Recognizer methods
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}

#pragma mark - TMAudioPlayerManagerDelegate methods

- (void)displayMark:(TMMark *)mark {
    
}

- (void)updateTimeInfoWithElapsedTime:(NSString *)elapsedTime andTimeSliderValue:(float)value {
    self.timeElapsedLabel.text = elapsedTime;
    self.timeSlider.value = value;
}

- (void)didFinishPlaying {
    //tell the nav controller we're not currently playing anything
    self.navController.currentAudioPlayerViewController = nil;
    
    if ([self presentedViewController] == nil) {
        //if we're not presenting anything, pop up the reviewVC so they can rate the episode
        [self showReviewVC:NO];
    }
    
    //pause the player and reset it to the beginning of the episode
    [self.audioPlayerManager seekToPosition:0 andPlay:NO];
}
@end
