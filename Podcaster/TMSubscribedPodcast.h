//
//  SubscribedPodcast.h
//  Podcaster
//
//  Created by Tyler Mikev on 4/24/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "TMPodcastProtocol.h"

@class TMPodcast;

@interface TMSubscribedPodcast : NSManagedObject <TMPodcastDelegate>

@property (strong, nonatomic) UIImage *podcastImage;

/**
 *  Inserts a TMSubscribedPodcast matching 'podcast' in the context, if one does not already exist.
 *  
 *  @param podcast An object conforming to TMPodcastDelegate that we'd like to save to the object graph if it doesn't already exist.
 *  returns A TMSubscribedPodcast populated with the data from 'podcast'
 */
+ (instancetype)instanceFromTMPodcast:(id<TMPodcastDelegate>)podcast inContext:(NSManagedObjectContext *)context;

@end
