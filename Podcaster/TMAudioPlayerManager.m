//
//  TMAudioPlayer.m
//  Podcaster
//
//  Created by Tyler Mikev on 3/6/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMAudioPlayerManager.h"
#import <AVFoundation/AVFoundation.h>
#import "TMMark.h"
#import "TMPodcastEpisode.h"

@interface TMAudioPlayerManager () <AVAudioPlayerDelegate>

@property (strong, nonatomic) AVPlayer *audioPlayer;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) TMMark *currentMark;
@property (strong, nonatomic) NSTimer *marksTimer;
@property (strong, nonatomic) NSMutableArray *marksArray;

@end

@implementation TMAudioPlayerManager

+ (instancetype)sharedInstance {
    static TMAudioPlayerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (AVPlayer *)audioPlayer {
    if (!_audioPlayer) {
        _audioPlayer = [[AVPlayer alloc] init];
    }

    return _audioPlayer;
}

- (void)setEpisode:(TMPodcastEpisode *)episode {
    if (self.episode == episode) {
        //if we're already playing the current episode,
        //don't do anything
        return;
    }
    _episode = episode;
    
    NSURL *fileURL = nil;
    if (episode.fileLocation) {
        fileURL = [NSURL fileURLWithPath:episode.fileLocation];
    } else if (episode.downloadURL) {
        fileURL = [NSURL URLWithString:episode.downloadURL.absoluteString];
    }
    
    self.playerItem = [AVPlayerItem playerItemWithURL:fileURL];
    [self.audioPlayer replaceCurrentItemWithPlayerItem:self.playerItem];
    [self.audioPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];

    if (self.delegate) {
        //fire back the initial time info to the delegate
        [self updateDelegateTimeInfo];
    }
}

- (void)setDelegate:(id<TMAudioPlayerManagerDelegate>)delegate {
    _delegate = delegate;
    
    if (self.episode && self.audioPlayer.rate != 0) {
        //fire an update immediately so that we have audio info when the VC displays
        [self updateDelegateTimeInfo];
        
        //start monitoring normally
        [self startMonitoringAudioTime];
    }
    
}

- (void)play {
    [self.audioPlayer play];
    
    //start the timer to monitor stuff
    [self startMonitoringAudioTime];
}

- (void)pause {
    [self.audioPlayer pause];
}

- (BOOL)isPlaying {
    return self.audioPlayer.rate > 0;
}

- (void)handlePlayPause {
    if ([self isPlaying]) {
        [self pause];
    } else {
        [self play];
    }
}

- (void)seekWithInterval:(float)seekTime {
    NSTimeInterval time = floor(seekTime + CMTimeGetSeconds(self.playerItem.currentTime));
    
    NSTimeInterval duration = CMTimeGetSeconds(self.playerItem.duration);
    if (time > duration) {
        time = duration;
    } else if (time < 0) {
        time = 0;
    }
    
    float sliderValue = time / CMTimeGetSeconds(self.playerItem.duration);
    [self seekToPosition:sliderValue];
}

- (void)seekToPosition:(float)value {
    int time = floor(value * CMTimeGetSeconds(self.playerItem.duration));
    
    CMTime seekTime = CMTimeMake(time, 1);
    [self.audioPlayer seekToTime:seekTime];
    [self.audioPlayer play];
    
    NSString *elapsedTime = [self formattedTimeForNSTimeInterval:time];
    [self.delegate updateTimeInfoWithElapsedTime:elapsedTime andTimeSliderValue:value];
}

- (NSString *)formattedTimeForNSTimeInterval:(NSTimeInterval)interval {
    NSInteger minutes = floor(interval/60);
    NSInteger seconds = (int)(interval)%60;
    NSString *formattedString = [NSString stringWithFormat:@"%li:%.2li", (long)minutes, seconds];
    
    return formattedString;
}

- (NSString *)fileDurationString {
    return [self formattedTimeForNSTimeInterval:self.episode.duration];
}

#pragma mark - Marks methods

- (void)startMonitoringAudioTime {
    if (!self.marksTimer) {
        self.marksTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(monitorTimeRelatedInfo)
                                                         userInfo:nil
                                                          repeats:YES];
    }
}

- (void)stopMonitoringAudioTime {
    [self.marksTimer invalidate];
    self.marksArray = nil;
}

- (void)loadMarks {
    
    NSError *jsonError;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"markers" ofType:@"json"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
    NSData *objectData = [NSData dataWithContentsOfURL:fileURL];
    NSMutableArray *unsortedMarksArray = [[[NSJSONSerialization JSONObjectWithData:objectData
                                                                           options:NSJSONReadingMutableContainers
                                                                             error:&jsonError] objectForKey:@"marks"] mutableCopy];
    if (jsonError) {
        NSLog(@"Error loading json : %@", jsonError);
    }
    
    if (!self.marksArray) {
        self.marksArray = [NSMutableArray new];
    } else {
        [self.marksArray removeAllObjects];
    }
    
    //sort the array so all the marks are in order
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
    unsortedMarksArray = [[unsortedMarksArray sortedArrayUsingDescriptors:@[descriptor]] mutableCopy];
    for (NSDictionary *dictionary in unsortedMarksArray) {
        TMMark *mark = [[TMMark alloc] initWithDictionary:dictionary];

        if (mark.time >= [self currentTime]) {
            [self.marksArray addObject:mark];
        }
    }
    
}

- (void)monitorTimeRelatedInfo {
    
    [self updateDelegateTimeInfo];
    
    if (self.marksArray) {
        [self checkForNextMark];
    }
}

- (void)updateDelegateTimeInfo {
    
    //update delegate
    NSString *elapsedTime = [self formattedTimeForNSTimeInterval:[self currentTime]];
    float value = [self currentTime] / [self duration];
    [self.delegate updateTimeInfoWithElapsedTime:elapsedTime andTimeSliderValue:value];
}

- (void)checkForNextMark {

    //check for mark
    TMMark *nextMark = [self.marksArray firstObject];
    
    if ([self currentTime] > nextMark.time) {
        //show this mark, set it as the current mark
        self.currentMark = nextMark;
        
        //send the mark to the delegate
        [self.delegate displayMark:self.currentMark];
        
        //remove this object since we've displayed it
        [self.marksArray removeObject:self.currentMark];
        
        if (self.marksArray.count == 0) {
            //if we've ran out of marks, stop the timer
            [self.marksTimer invalidate];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == self.audioPlayer && [keyPath isEqualToString:@"status"]) {
        if (self.audioPlayer.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayer Failed");
        } else if (self.audioPlayer.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
        } else if (self.audioPlayer.status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");
        }
    }
}

- (NSTimeInterval)currentTime {
    NSTimeInterval currentTime = CMTimeGetSeconds(self.playerItem.currentTime);
    return currentTime;
}

- (NSTimeInterval)duration {
    NSTimeInterval duration = CMTimeGetSeconds(self.playerItem.duration);
    return duration;
}

@end
