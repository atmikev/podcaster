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

@interface TMAudioPlayerManager () <AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) TMMark *currentMark;
@property (strong, nonatomic) NSTimer *marksTimer;
@property (strong, nonatomic) NSMutableArray *marksArray;


@end

@implementation TMAudioPlayerManager

- (instancetype) initWithDelegate:(id<TMAudioPlayerManagerDelegate>)delegate {
    self = [super init];
    
    if (self) {
        self.delegate = delegate;
    }
    
    return self;
}

- (void)playFileAtURL:(NSURL *)fileURL {
    
    //get the audioplayer ready
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    self.audioPlayer.delegate = self;
    if (error) {
        NSLog(@"Error initing audio player: %@", error);
    }
    
    //start the timer
    [self startMonitoringAudioTime];

}

- (void)stopPlayingFile {
    [self.audioPlayer stop];
}


#pragma mark - Marks methods

- (void)startMonitoringAudioTime {
    self.marksTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(checkForMark)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stopMonitoringAudioTime {
    [self.marksTimer invalidate];
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
        if (mark.time >= [self.audioPlayer currentTime]) {
            [self.marksArray addObject:mark];
        }
    }
    
}

- (void)checkForMark {
    
    NSTimeInterval currentTime = [self.audioPlayer currentTime];
    TMMark *nextMark = [self.marksArray firstObject];
    
    if (currentTime > nextMark.time) {
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

#pragma AVAudioPlayerDelegate methods

/* audioPlayerDidFinishPlaying:successfully: is called when a sound has finished playing. This method is NOT called if the player is stopped due to an interruption. */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
#warning TODO
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
#warning TODO
}

@end
