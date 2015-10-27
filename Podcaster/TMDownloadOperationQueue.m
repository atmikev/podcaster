//
//  TMDownloadOperationQueue.m
//  Podcaster
//
//  Created by Tyler Mikev on 7/11/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMDownloadOperationQueue.h"
#import "TMPodcastEpisodeProtocol.h"
#import "TMDownloadOperation.h"

@interface TMDownloadOperationQueue ()
@property (strong, nonatomic) NSMutableDictionary *downloadingDictionary;
@end

@implementation TMDownloadOperationQueue

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _downloadingDictionary = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)addOperation:(NSOperation *)op {
    [super addOperation:op];
    
    //store the download in the dictionary so it can be cancelled later
    TMDownloadOperation *downloadOp = (TMDownloadOperation *)op;
    [self.downloadingDictionary setValue:op forKey:downloadOp.downloadURLString];
}

- (void)cancelDownloadForEpisode:(id<TMPodcastEpisodeDelegate>)episode {
    
    if (episode) {
        //get the downloadOp so we can cancel it
        TMDownloadOperation *downloadOp = [self.downloadingDictionary objectForKey:episode.downloadURLString];
        
        [downloadOp cancel];
        
        //remove the download from the dictionary
        [self.downloadingDictionary removeObjectForKey:downloadOp.downloadURLString];
    }
}
@end
