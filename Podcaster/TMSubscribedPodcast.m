//
//  SubscribedPodcast.m
//  Podcaster
//
//  Created by Tyler Mikev on 4/24/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMSubscribedPodcast.h"
#import "TMPodcast.h"
#import "TMDownloadUtilities.h"
#import "NSManagedObject+EntityName.h"

@interface TMSubscribedPodcast ()

@property (nonatomic, retain) NSString *imageURLLocal;

@end

@implementation TMSubscribedPodcast

@synthesize podcastDescription = _podcastDescription;
@synthesize episodes = _episodes;
@synthesize podcastImage = _podcastImage;
@dynamic imageURLLocal;
@dynamic feedURLString;
@dynamic title;

#warning Move writing to the DB to a background threaded context
+ (instancetype)instanceFromTMPodcast:(id<TMPodcastDelegate>)podcast inContext:(NSManagedObjectContext *)context {
    
    //if we've already subscribed to this podcast, get it
    TMSubscribedPodcast *subscribedPodcast = [self subscribedPodcastWithName:podcast.title inContext:context];
    
    //otherwise make a new one
    if (subscribedPodcast == nil) {
        subscribedPodcast = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
        subscribedPodcast.title = podcast.title;
        subscribedPodcast.feedURLString = podcast.feedURLString;
        subscribedPodcast.podcastDescription = podcast.podcastDescription;
        [subscribedPodcast saveImageToDisk:podcast.podcastImage
                                forPodcast:podcast
                            withCompletion:^(NSString *localURLString) {
            subscribedPodcast.imageURLLocal = localURLString;
        }];
        subscribedPodcast.episodes = nil;
        
        //save
        NSError *saveError = nil;
        if (![context save:&saveError]) {
            NSLog(@"error saving when trying to insert a TMSubscribedPodcast named %@.\nError description: %@", subscribedPodcast.title, saveError.localizedDescription);
        }
    }
    
    return subscribedPodcast;
}

+ (TMSubscribedPodcast *)subscribedPodcastWithName:(NSString *)podcastTitle inContext:(NSManagedObjectContext *)context {
    
    //fetch all subscribed podcasts
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:[self entityName]
                                              inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@", podcastTitle];
    [request setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:request error:nil];
    
    TMSubscribedPodcast *subscribedPodcast = [results firstObject];
    
    return subscribedPodcast;
}

- (UIImage *)podcastImage {
    if (!_podcastImage) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[self.imageURLLocal lastPathComponent]];
        
        _podcastImage = [UIImage imageWithContentsOfFile:filePath];
    }
    
    return _podcastImage;
}


- (void)saveImageToDisk:(UIImage *)image forPodcast:(TMPodcast *)podcast withCompletion:(void(^)(NSString *localURLString))completionBlock{
    NSData *data = UIImagePNGRepresentation(image);
    NSString *titleNoSpaces = [podcast.title stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *fileName = [NSString stringWithFormat:@"%@-image.png", titleNoSpaces];
    NSError *saveError;
    NSString *filePath = [TMDownloadUtilities saveData:data withFileName:fileName andError:saveError];
    if (saveError) {
        NSLog(@"Error saving image for subscribedPodcast %@ : %@", podcast.title, saveError.localizedDescription);
        completionBlock(nil);
    } else if (completionBlock) {
        completionBlock(filePath);
    }

}

@end
