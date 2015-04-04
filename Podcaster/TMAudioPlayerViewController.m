//
//  TMAudioPlayerViewController.m
//  Podcaster
//
//  Created by Tyler Mikev on 3/10/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMAudioPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface TMAudioPlayerViewController ()

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation TMAudioPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *fileURL = [NSURL URLWithString:self.episode.fileLocation];
    NSError *fileError;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&fileError];
    
    if (fileError) {
        NSLog(@"error loading the file: %@",fileError.localizedDescription);
    }

}

- (IBAction)playPause:(id)sender {
    if (self.audioPlayer.isPlaying) {
        [self.audioPlayer stop];
    } else {
        [self.audioPlayer play];
    }
}

@end
