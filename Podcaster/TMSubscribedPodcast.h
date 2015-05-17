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
#import "NSManagedObject+EntityName.h"
#import "TMPodcastProtocol.h"

@class TMPodcast;

@interface TMSubscribedPodcast : NSManagedObject <TMPodcastDelegate>

@property (strong, nonatomic) UIImage *podcastImage;
@property (strong, nonatomic) NSString *imageURLRemote;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray *episodes;

+ (instancetype)instanceFromTMPodcast:(TMPodcast *)podcast inContext:(NSManagedObjectContext *)context;

@end
