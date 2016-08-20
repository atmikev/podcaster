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
#import "TMPodcastEpisode.h"
#import "TMSubscribedEpisode.h"
#import "TMPodcastEpisodeProtocol.h"
#import "TMDeeplink.h"
#import <Parse/Parse.h>
#import <Social/Social.h>

static NSString * const kPlayImageString = @"play";
static NSString * const kPauseImageString = @"pause";
static NSString * const kIsPlayingString = @"isPlaying";
static NSString * const kIsReadyToPlayString = @"isReadyToPlay";
static NSString * const kReviewViewControllerSegueString = @"reviewViewControllerSegue";

@interface TMAudioPlayerViewController () <TMAudioPlayerManagerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) TMAudioPlayerManager *audioPlayerManager;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) TMNavigationController *navController;
@property (assign, nonatomic) BOOL initiatedByUser;
@property (assign, nonatomic) BOOL isFirstAppearance;

@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIImageView *podcastImageView;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;
@property (weak, nonatomic) IBOutlet UILabel *timeElapsedLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeTotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *rateButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

- (IBAction)playPause:(id)sender;
- (IBAction)timeSliderValueChanged:(id)sender;
- (IBAction)seekBackHandler:(id)sender;
- (IBAction)seekForwardHandler:(id)sender;

@end

@implementation TMAudioPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //use this to prevent us from playing ever time viewDidAppear gets called
    self.isFirstAppearance = NO;
    
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
    
    //kvo on isPlaying for the play/pause image
    [self.audioPlayerManager addObserver:self
                              forKeyPath:kIsPlayingString
                                 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                 context:nil];
    
    [self checkIfWeAreReadyToPlay];
    
    //workaround for ios 8 bug to prevent accidentally swiping back when trying to use the time bar
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    //start receiving remote control events
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}



- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    //seems intermittent...should come back to this though
    @try {
        [self.audioPlayerManager removeObserver:self forKeyPath:kIsPlayingString];
    }
    @catch (NSException * __unused exception) {}

}

- (void)setupAudioPlayerManager {
    self.audioPlayerManager = [TMAudioPlayerManager sharedInstance];
    self.audioPlayerManager.delegate = self;
    self.audioPlayerManager.episode = self.episode;
}

- (void)checkIfWeAreReadyToPlay {
    //check if we're ready to play
    if (self.audioPlayerManager.isReadyToPlay == NO) {
        //kvo on isReadyToPlay to show whether the audio player is ready to play or not
        [self.audioPlayerManager addObserver:self
                                  forKeyPath:kIsReadyToPlayString
                                     options:NSKeyValueObservingOptionNew
                                     context:nil];

        //show the user we can't interact quite yet
        self.playPauseButton.enabled = NO;
        self.playPauseButton.alpha = 0.5;
        
    } else {
        [self readyToPlay];
    }

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
    [self setupPlayUI];
}

- (void)playAudioFromLastPlayedLocation {
    [self.audioPlayerManager playFromLastPlayedLocation];
    [self setupPlayUI];
}

- (void)setupPlayUI {
    [self changePlayPauseButtonImage:YES];
    self.navController.currentAudioPlayerViewController = self;
}

- (void)showReviewVC:(BOOL)initiatedByUser {

    //track who initiated the review
    self.initiatedByUser = initiatedByUser;
    [self performSegueWithIdentifier:kReviewViewControllerSegueString sender:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:kIsPlayingString]) {
        BOOL isPlaying = [(NSNumber *)[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        [self changePlayPauseButtonImage:isPlaying];
    } else if ([keyPath isEqualToString:kIsReadyToPlayString]) {
        [self readyToPlay];
        //unregister for ready to play, because the audioplayer will be ready to play for the rest of the app's existence
        [self.audioPlayerManager removeObserver:self forKeyPath:kIsReadyToPlayString];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:kReviewViewControllerSegueString]) {
        TMReviewViewController *reviewVC = [segue destinationViewController];
        reviewVC.initiatedByUser = self.initiatedByUser;
        reviewVC.episode = self.episode;
    }
    
}

-(void)togglePlayPause {
    if (self.audioPlayerManager.isPlaying) {
        [self pauseAudio];
    } else {
        [self playAudio];
    }
}

#pragma mark - IBActions

- (IBAction)playPause:(id)sender {
    [self togglePlayPause];
}

- (IBAction)timerStartedSliding:(id)sender {
    //stop the audioplayer so the slider doesn't jerk around
    [self.audioPlayerManager pause];
}

- (IBAction)timeSliderValueChanged:(id)sender {
    [self.audioPlayerManager seekToPosition:self.timeSlider.value andPlay:YES];
}

- (IBAction)seekBackHandler:(id)sender {
    [self.audioPlayerManager seekWithInterval:-kSeekInterval];
}

- (IBAction)seekForwardHandler:(id)sender {
    [self.audioPlayerManager seekWithInterval:kSeekInterval];
}

- (IBAction)rateButtonHandler:(id)sender {
    [self showReviewVC:YES];
}
- (IBAction)shareButtonHandler:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@"Where do you want to share this epidose?"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* facebookAction = [UIAlertAction actionWithTitle:@"Facebook"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               [self sharePodcastEpisode:self.episode forSelection:(NSString *)SLServiceTypeFacebook];
                                                           }];
    
    UIAlertAction* twitterAction = [UIAlertAction actionWithTitle:@"Twitter"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self sharePodcastEpisode:self.episode forSelection:(NSString *)SLServiceTypeTwitter];
                                                          }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [alert addAction:facebookAction];
    [alert addAction:twitterAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];

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

- (void)readyToPlay {
    
    self.playPauseButton.enabled = YES;
    self.playPauseButton.alpha = 1.0;
    
    //start the episode
    [self playAudioFromLastPlayedLocation];
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

#pragma mark - Social Share Episode methods
-(void)sharePodcastEpisode:(id<TMPodcastEpisodeDelegate>)episode forSelection:(NSString *)selection {
    TMDeeplink *deeplink = [TMDeeplink initWithPodcastData:episode.collectionId
                                          withEpisodeTitle:episode.title];
    [deeplink shareDeeplink:deeplink
            withServiceType:selection
                  withImage:self.podcastImage
        withCompletionBlock:^(SLComposeViewController *shareContent) {
            
        if (shareContent) {
            [self presentViewController:shareContent animated:true completion:nil];
        }
        
    }];
    
}
@end
