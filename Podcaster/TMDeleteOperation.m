//
//  TMDeleteOperation.m
//  Podcaster
//
//  Created by Tyler Mikev on 7/11/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMDeleteOperation.h"
#import "TMPodcastEpisodeProtocol.h"
#import "TMCoreDataManager.h"
#import "TMSubscribedEpisode.h"
@import CoreData;

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
            [self deleteFileLocation];
        }
    }
    
}

- (void)deleteFileLocation {
    //get the episode from the db, erase the file location, and save
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext = [[TMCoreDataManager sharedInstance] mainThreadManagedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TMSubscribedEpisode" inManagedObjectContext:temporaryContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileLocation == %@",self.episode.fileLocation];
    [fetchRequest setPredicate:predicate];
    
    NSError *fetchError;
    NSArray *results = [temporaryContext executeFetchRequest:fetchRequest error:&fetchError];
    
    if (results.count > 0) {
        TMSubscribedEpisode *episodeToDeleteDownload = [results firstObject];
        episodeToDeleteDownload.fileLocation = nil;
        
        [temporaryContext performBlock:^{
            NSError *saveError;
            if (![temporaryContext save:&saveError]) {
                NSLog(@"Error saving episode after removing its fileLocation: %@", saveError.debugDescription);
            }
        }];
        
    }
}


@end
