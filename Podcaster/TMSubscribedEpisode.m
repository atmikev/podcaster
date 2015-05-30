//
//  SubscribedEpisode.m
//  Podcaster
//
//  Created by Tyler Mikev on 4/24/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMSubscribedEpisode.h"
#import "TMSubscribedPodcast.h"
#import "TMPodcastEpisode.h"
#import "NSManagedObject+EntityName.h"

@interface TMSubscribedEpisode ()

@property (strong, nonatomic) TMSubscribedPodcast *subscribedPodcast;

@end

@implementation TMSubscribedEpisode

@dynamic duration;
@dynamic episodeNumber;
@dynamic fileLocation;
@dynamic fileSize;
@dynamic publishDate;
@dynamic title;
@dynamic downloadURLString;
@dynamic lastPlayLocation;
@dynamic subscribedPodcast;
@synthesize podcast;

#warning Move writing to the DB to a background threaded context
+ (instancetype)instanceFromTMPodcastEpisode:(id<TMPodcastEpisodeDelegate>)episode inContext:(NSManagedObjectContext *)context {
    
    //if we've already subscribed to this podcast, get it
    TMSubscribedEpisode *subscribedEpisode = [self subscribedPodcastEpisodeWithName:episode.title inContext:context];
    
    //otherwise make a new one
    if (subscribedEpisode == nil) {
        subscribedEpisode = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
        subscribedEpisode.title = episode.title;
        subscribedEpisode.downloadURLString = episode.downloadURLString;
        subscribedEpisode.duration = episode.duration;
        subscribedEpisode.episodeNumber = episode.episodeNumber;
        subscribedEpisode.fileLocation = episode.fileLocation;
        subscribedEpisode.fileSize = episode.fileSize;
        subscribedEpisode.publishDate = episode.publishDate;
        subscribedEpisode.lastPlayLocation = episode.lastPlayLocation;
        subscribedEpisode.subscribedPodcast = [TMSubscribedPodcast instanceFromTMPodcast:episode.podcast inContext:context];
        
        //save
        NSError *saveError = nil;
        if (![context save:&saveError]) {
            NSLog(@"error saving when trying to insert a TMSubscribedEpisode named %@.\nError description: %@", subscribedEpisode.title, saveError.localizedDescription);
        }
    }
    
    return subscribedEpisode;
}

+ (instancetype)subscribedPodcastEpisodeWithName:(NSString *)podcastTitle inContext:(NSManagedObjectContext *)context {
    
    //fetch all subscribed podcasts
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:[self entityName]
                                              inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@", podcastTitle];
    [request setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:request error:nil];
    
    TMSubscribedEpisode *subscribedEpisode = [results firstObject];
    
    return subscribedEpisode;
}

- (id<TMPodcastDelegate>)podcast {
    return self.subscribedPodcast;
}

@end
