//
//  SubscribedEpisode.h
//  Podcaster
//
//  Created by Tyler Mikev on 4/24/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TMSubscribedEpisode : NSManagedObject

@property (strong, nonatomic) NSNumber * duration;
@property (strong, nonatomic) NSNumber * episodeNumber;
@property (strong, nonatomic) NSString * fileLocation;
@property (strong, nonatomic) NSNumber * fileSize;
@property (strong, nonatomic) NSDate * publishDate;
@property (strong, nonatomic) NSString * title;

@end
