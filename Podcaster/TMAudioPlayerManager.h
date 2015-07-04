//
//  TMAudioPlayer.h
//  Podcaster
//
//  Created by Tyler Mikev on 3/6/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

@import Foundation;
@import CoreData;

@class TMMark;
@class TMPodcastEpisode;

@protocol TMAudioPlayerManagerDelegate <NSObject>
- (void)didFinishPlaying;
- (void)displayMark:(TMMark *)mark;
- (void)updateTimeInfoWithElapsedTime:(NSString *)elapsedTime andTimeSliderValue:(float)value;
@end

FOUNDATION_EXPORT const NSInteger kSeekInterval;

@interface TMAudioPlayerManager : NSObject

@property (weak, nonatomic) id<TMAudioPlayerManagerDelegate> delegate;
@property (strong, nonatomic) TMPodcastEpisode *episode;
@property (assign, nonatomic, readonly) BOOL isPlaying;
@property (assign, nonatomic, readonly) BOOL isReadyToPlay;
@property (assign, nonatomic, readonly) NSTimeInterval currentTime;
@property (assign, nonatomic, readonly) NSTimeInterval duration;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (instancetype)sharedInstance;

- (NSString *)fileDurationString;

- (void)startSeekingForwardContinuously;

- (void)startSeekingBackwardContinuously;

- (void)stopSeekingContinuously;

- (void)seekWithInterval:(float)seekTime;

- (void)seekToPosition:(float)value andPlay:(BOOL)shouldPlay;

- (void)pause;

- (void)play;
- (void)playFromLastPlayedLocation;

- (void)togglePlayPause;
@end
