//
//  TMAudioPlayerViewController.m
//  Podcaster
//
//  Created by Tyler Mikev on 3/10/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMAudioPlayerViewController.h"
#import "TMAudioPlayerManager.h"
#import "TMMark.h"

@interface TMAudioPlayerViewController () <TMAudioPlayerManagerDelegate>

@property (strong, nonatomic) TMAudioPlayerManager *audioPlayerManager;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) TMMark *currentMark;

@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIImageView *podcastImageView;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;
@property (weak, nonatomic) IBOutlet UILabel *timeElapsedLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeTotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


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
    
    //add gestureRecognizer to imageView
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCurrentMark)];
    [self.podcastImageView addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [self playAudio];
}

- (void)setupAudioPlayerManager {
    self.audioPlayerManager = [TMAudioPlayerManager sharedInstance];
    self.audioPlayerManager.delegate = self;
    self.audioPlayerManager.episode = self.episode;
}

- (void)setupSeekSlider {
    self.timeSlider.value = 0;
}

- (void)pauseAudio {
    [self.audioPlayerManager pause];
    [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
}

- (void)playAudio {
    [self.audioPlayerManager play];
    [self.playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
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
    [self.audioPlayerManager seekToPosition:self.timeSlider.value];
}

- (IBAction)seekBackHandler:(id)sender {
    [self.audioPlayerManager seekWithInterval:-15];
}

- (IBAction)seekForwardHandler:(id)sender {
    [self.audioPlayerManager seekWithInterval:15];
}

- (void)tappedCurrentMark {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.currentMark.link]];
}

#pragma mark - TMAudioPlayerManagerDelegate methods

- (void)displayMark:(TMMark *)mark {
    
    //store the current mark incase the user interacts with it
    self.currentMark = mark;
    
    UIImage *markImage = [UIImage imageNamed:mark.imageLocation];
    self.podcastImageView.image = markImage;
    
}

- (void)updateTimeInfoWithElapsedTime:(NSString *)elapsedTime andTimeSliderValue:(float)value {
    self.timeElapsedLabel.text = elapsedTime;
    self.timeSlider.value = value;
}


@end
