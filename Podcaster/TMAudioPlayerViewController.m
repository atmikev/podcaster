//
//  TMAudioPlayerViewController.m
//  Podcaster
//
//  Created by Tyler Mikev on 3/10/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMAudioPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface TMAudioPlayerViewController () <AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation TMAudioPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAudioPlayer];

    [self setupSeekSlider];
    
    [self setupTimeLabels];
    
    //show podcast image
    self.podcastImageView.image = self.podcastImage;
}

- (void)setupTimeLabels {
    self.timeElapsedLabel.text = [self formattedTimeForNSTimeInterval:0];
    
    self.timeTotalLabel.text = [self formattedTimeForNSTimeInterval:self.audioPlayer.duration];
}

- (void)setupSeekSlider {
    self.timeSlider.value = 0;
    //prevents continuous updates while dragging the seek slider
//    [self.timeSlider setContinuous:NO];
}

- (void)setupAudioPlayer {
    NSURL *fileURL = [NSURL URLWithString:self.episode.fileLocation];
    NSError *fileError;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&fileError];
    
    self.audioPlayer.delegate = self;
    
    if (fileError) {
        NSLog(@"error loading the file: %@",fileError.localizedDescription);
    }
}

- (NSString *)formattedTimeForNSTimeInterval:(NSTimeInterval)interval {
    NSInteger minutes = floor(interval/60);
    NSInteger seconds = (int)(interval)%60;
    NSString *formattedString = [NSString stringWithFormat:@"%li:%.2li", (long)minutes, seconds];
    
    return formattedString;
}

- (void)stopAudio {
    [self.audioPlayer stop];
    [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
    
    //stop timer
    [self.timer invalidate];
    
    
}

- (void)playAudio {
    [self.audioPlayer play];
    [self.playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    
    //start timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(updateTimeInfo)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)updateTimeInfo {
    NSTimeInterval currentTime = self.audioPlayer.currentTime;
    self.timeElapsedLabel.text = [self formattedTimeForNSTimeInterval:currentTime];
    self.timeSlider.value = currentTime/self.audioPlayer.duration;
}

- (IBAction)playPause:(id)sender {
    if (self.audioPlayer.isPlaying) {
        [self stopAudio];
    } else {
        [self playAudio];
    }
}

- (IBAction)timerStartedSliding:(id)sender {
    //stop the audioplayer so the slider doesn't jerk around
    [self stopAudio];
}

- (IBAction)timeSliderValueChanged:(id)sender {
    NSTimeInterval seekTime = floor(self.timeSlider.value * self.audioPlayer.duration);
    
    self.timeElapsedLabel.text = [self formattedTimeForNSTimeInterval:seekTime];
    self.audioPlayer.currentTime = seekTime;
}

#pragma mark - AVAudioPlayer delegates



@end
