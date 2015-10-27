//
//  SubscribedEpisode.h
//  Podcaster
//
//  Created by Tyler Mikev on 4/24/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TMPodcastEpisodeProtocol.h"

@class TMSubscribedPodcast;
@class TMPodcastEpisode;

@interface TMSubscribedEpisode : NSManagedObject <TMPodcastEpisodeDelegate>

//returns an instance based on 'episode'. Creates a new instance in the db if one does not already exist
+ (instancetype)instanceFromTMPodcastEpisode:(id<TMPodcastEpisodeDelegate>)episode inContext:(NSManagedObjectContext *)context;

//returns an instance iff one already exists in the db
+ (instancetype)subscribedPodcastEpisodeWithName:(NSString *)podcastTitle inContext:(NSManagedObjectContext *)context;

@end

