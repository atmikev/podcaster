//
//  TMAudioPlayer.h
//  Podcaster
//
//  Created by Tyler Mikev on 3/6/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMMark;
@class TMPodcastEpisode;

@protocol TMAudioPlayerManagerDelegate <NSObject>
- (void)didFinishPlaying;
- (void)displayMark:(TMMark *)mark;
- (void)updateTimeInfoWithElapsedTime:(NSString *)elapsedTime andTimeSliderValue:(float)value;
@end


@interface TMAudioPlayerManager : NSObject

@property (weak, nonatomic) id<TMAudioPlayerManagerDelegate> delegate;
@property (strong, nonatomic) TMPodcastEpisode *episode;
@property (assign, nonatomic, readonly) BOOL isPlaying;
@property (assign, nonatomic, readonly) BOOL isReadyToPlay;
@property (assign, nonatomic, readonly) NSTimeInterval currentTime;
@property (assign, nonatomic, readonly) NSTimeInterval duration;

+ (instancetype)sharedInstance;

- (NSString *)fileDurationString;

- (void)seekWithInterval:(float)seekTime;

- (void)seekToPosition:(float)value andPlay:(BOOL)shouldPlay;

- (void)handlePlayPause;

- (void)pause;

- (void)play;


@end
