//
//  TMAudioPlayer.m
//  Podcaster
//
//  Created by Tyler Mikev on 3/6/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMAudioPlayerManager.h"
#import "TMMark.h"
#import "TMPodcastEpisode.h"
#import "TMPodcastProtocol.h"
#import <Parse/Parse.h>
@import MediaPlayer;
@import AVFoundation;

static NSString * const dateFormatterString = @"yyyy-MM-dd HH zzz";
const NSInteger kSeekInterval = 15;

@interface TMAudioPlayerManager () <AVAudioPlayerDelegate>

@property (strong, nonatomic) AVPlayer *audioPlayer;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) TMMark *currentMark;
@property (strong, nonatomic) NSTimer *marksTimer;
@property (strong, nonatomic) NSMutableArray *marksArray;
@property (assign, nonatomic, readwrite) BOOL isPlaying;
@property (assign, nonatomic, readwrite) BOOL isReadyToPlay;
@property (assign, nonatomic, readwrite) NSTimeInterval currentTime;
@property (assign, nonatomic, readwrite) NSTimeInterval duration;
@property (strong, nonatomic) NSTimer *seekTimer;
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
        
        //KVO on AVPlayerItemStatusReadyToPlay to let our delegate know when we can show the play button
        [_audioPlayer addObserver:self
                       forKeyPath:@"status"
                          options:(NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew)
                          context:nil];
        
        [self registerForRemoteEvents];
    }
    
    return _audioPlayer;
}

- (void)registerForRemoteEvents {

    //register for remote events
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    //play event
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
        [self play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    //pause event
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
        [self pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    //seek backward event
    [commandCenter.skipBackwardCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
        [self seekWithInterval:-kSeekInterval];
        return MPRemoteCommandHandlerStatusSuccess;
    }];

    //seek forward event
    [commandCenter.skipForwardCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
        [self seekWithInterval:kSeekInterval];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self play];
                break;
                
            case UIEventSubtypeRemoteControlPause:
                [self pause];
                break;
                
            default:
                break;
        }
    }
}

- (void)setEpisode:(TMPodcastEpisode *)episode {
    if ([episode isEqual:self.episode]) {
        //if we're already playing the current episode,
        //don't do anything
        return;
    }
    _episode = episode;
    
    NSURL *fileURL = nil;
    if (episode.fileLocation) {
        fileURL = [NSURL fileURLWithPath:episode.fileLocation];
    } else if (episode.downloadURLString) {
        fileURL = [NSURL URLWithString:episode.downloadURLString];
    }
    
    self.playerItem = [AVPlayerItem playerItemWithURL:fileURL];
    [self.audioPlayer replaceCurrentItemWithPlayerItem:self.playerItem];
    [self.audioPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];

    if (self.delegate) {
        //fire back the initial time info to the delegate
        [self updateDelegateTimeInfo];
    }
    
    //update the now playing info
    [self updateNowPlayingInfo];
    
    //track finished event
    [PFAnalytics trackEvent:@"start" dimensions:[self startFinishDimensions]];

}

- (void)updateNowPlayingInfo {
    
    NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
    
    
    MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:self.episode.podcast.podcastImage];
    
    [songInfo setObject:self.episode.title forKey:MPMediaItemPropertyTitle];
    [songInfo setObject:self.episode.podcast.title forKey:MPMediaItemPropertyArtist];
    [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    
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

- (void)readyToPlay {
    //let everyone know we're ready to play
    self.isReadyToPlay = YES;
}

- (void)play {

    [self.audioPlayer play];
    
    //update the isPlaying value
    self.isPlaying = YES;
    
    //start the timer to monitor stuff
    [self startMonitoringAudioTime];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //pay attention to when the player has reached the end to let our owner know
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itemDidFinishPlaying:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.playerItem];
        
    });
    
//    NSInteger lastPlayedTime = [self.episode.lastPlayLocation integerValue];
//    
//    CMTime startPlayingTime = CMTimeMake(lastPlayedTime, 1);
//    
//    [self.audioPlayer seekToTime:startPlayingTime completionHandler:^(BOOL finished) {
//        if (finished) {
//            
//            [self.audioPlayer play];
//            
//            //update the isPlaying value
//            self.isPlaying = YES;
//            
//            //start the timer to monitor stuff
//            [self startMonitoringAudioTime];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                //pay attention to when the player has reached the end to let our owner know
//                [[NSNotificationCenter defaultCenter] addObserver:self
//                                                         selector:@selector(itemDidFinishPlaying:)
//                                                             name:AVPlayerItemDidPlayToEndTimeNotification
//                                                           object:self.playerItem];
//                
//            });
//
//        }
//    }];

}

- (void)pause {
    [self.audioPlayer pause];
    
    //update isPlaying
    self.isPlaying = NO;

}

- (void)togglePlayPause {
    //Note: Track play/pause analytics here to prevent accidental play/pause tracking caused by seeking
    if ([self isPlaying]) {
        [self pause];
        //track the pause event
        [PFAnalytics trackEvent:@"pause" dimensions:[self playPauseDimensions]];
    } else {
        [self play];
        //track the play event
        [PFAnalytics trackEvent:@"play" dimensions:[self playPauseDimensions]];
    }
}

- (void)startSeekingForwardContinuously {
    if (self.seekTimer != nil) {
        [self.seekTimer invalidate];
    }

    self.seekTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                      target:self
                                                    selector:@selector(seekForward)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)startSeekingBackwardContinuously {
    if (self.seekTimer != nil) {
        [self.seekTimer invalidate];
    }
    
    self.seekTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                      target:self
                                                    selector:@selector(seekBackward)
                                                    userInfo:nil
                                                     repeats:YES];

}

- (void)stopSeekingContinuously {
    [self.seekTimer invalidate];
}

- (void)seekForward {
    [self seekWithInterval:kSeekInterval];
}

- (void)seekBackward {
    [self seekWithInterval:-kSeekInterval];
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
    [self seekToPosition:sliderValue andPlay:YES];
}

- (void)seekToPosition:(float)value andPlay:(BOOL)shouldPlay {
    int time = floor(value * CMTimeGetSeconds(self.playerItem.duration));
    
    //track seek event
    [PFAnalytics trackEvent:@"seek" dimensions:[self seekDimensionsWithSeekToTime:time]];
    
    CMTime seekTime = CMTimeMake(time, 1);
    [self.audioPlayer seekToTime:seekTime];
    
    if (shouldPlay) {
        [self play];
    } else {
        [self pause];
    }
    
    NSString *elapsedTime = [self formattedTimeForNSTimeInterval:time];
    [self.delegate updateTimeInfoWithElapsedTime:elapsedTime andTimeSliderValue:value];
}

- (NSString *)formattedTimeForNSTimeInterval:(NSTimeInterval)interval {
    NSInteger minutes = floor(interval/60);
    NSInteger seconds = (int)(interval)%60;
    NSString *formattedString = [NSString stringWithFormat:@"%li:%.2li", (long)minutes, (long)seconds];
    
    return formattedString;
}

- (NSString *)fileDurationString {
    return [self formattedTimeForNSTimeInterval:[self.episode.duration doubleValue]];
}

- (void)itemDidFinishPlaying:(id)sender {
    
    //unregister for the notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //update isPlaying
    self.isPlaying = NO;
    
    //set the lastPlayedTime back to 0
    self.episode.lastPlayLocation = @(0);
    
    //tell the delegate we're done
    [self.delegate didFinishPlaying];
    
    //track finished event
    [PFAnalytics trackEvent:@"finished" dimensions:[self startFinishDimensions]];
}

#pragma mark - Marks methods

- (NSTimeInterval)currentTime {
    NSTimeInterval currentTime = CMTimeGetSeconds(self.playerItem.currentTime);
    return currentTime;
}

- (NSTimeInterval)duration {
    NSTimeInterval duration = CMTimeGetSeconds(self.playerItem.duration);
    return duration;
}

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
    
    //mark the last played time (can this be optimized?)
    self.episode.lastPlayLocation = [NSNumber numberWithDouble:[self currentTime]];
    
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

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == self.audioPlayer && [keyPath isEqualToString:@"status"]) {
        if (self.audioPlayer.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayer Failed");
        } else if (self.audioPlayer.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            [self readyToPlay];
        } else if (self.audioPlayer.status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");
        }
    }
}

#pragma mark - Analytics Dimensions

- (NSDictionary *)playPauseDimensions {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:dateFormatterString options:0 locale:[NSLocale currentLocale]]];
    
    NSDictionary *dimensions =  @{@"podcast":self.episode.podcast.title,
                                 @"episode":self.episode.title,
                                 @"episodeTime":[NSString stringWithFormat:@"%f",self.currentTime],
                                 @"dateTime":[dateFormatter stringFromDate:[NSDate date]]};
    
    return dimensions;
}

- (NSDictionary *)seekDimensionsWithSeekToTime:(NSInteger)seekToTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:dateFormatterString options:0 locale:[NSLocale currentLocale]]];

    
    NSDictionary *dimensions =  @{@"podcast":self.episode.podcast.title,
                                  @"episode":self.episode.title,
                                  @"episodeTime":[NSString stringWithFormat:@"%f",self.currentTime],
                                  @"seekToTime":[NSString stringWithFormat:@"%li",(long)seekToTime],
                                  @"dateTime":[dateFormatter stringFromDate:[NSDate date]]};
    
    return dimensions;
}

- (NSDictionary *)startFinishDimensions {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:dateFormatterString options:0 locale:[NSLocale currentLocale]]];
        
    NSDictionary *dimensions =  @{@"podcast":self.episode.podcast.title,
                                  @"episode":self.episode.title,
                                  @"dateTime":[dateFormatter stringFromDate:[NSDate date]]};
    
    return dimensions;
}

@end
