//
//  TMDeleteOperation.m
//  Podcaster
//
//  Created by Tyler Mikev on 7/11/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMDeleteOperation.h"
#import "TMPodcastEpisodeProtocol.h"

@interface TMDeleteOperation()
@property (strong, nonatomic) NSObject<TMPodcastEpisodeDelegate> *episode;
@end

@implementation TMDeleteOperation

- (instancetype)initWithEpisode:(id<TMPodcastEpisodeDelegate>)episode {
    self = [super init];
    
    if (self) {
        _episode = episode;
    }
    
    return self;
}

- (void)main {
    
    if ([self isCancelled]) {
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.episode.fileLocation]) {
        NSError *deleteError;
        [fileManager removeItemAtPath:self.episode.fileLocation error:&deleteError];
        
        if (deleteError) {
            NSLog(@"Error deleting episode: %@", deleteError.debugDescription);
        } else {
            self.episode.fileLocation = nil;
        }
    }
    
}


@end
