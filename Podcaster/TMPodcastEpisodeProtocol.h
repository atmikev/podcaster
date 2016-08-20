//
//  TMPodcastEpisodeProtocol.h
//  Podcaster
//
//  Created by Tyler Mikev on 5/29/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

@class TMSubscribedPodcast;
@protocol TMPodcastDelegate;

static NSString * const kDownloadPercentageKey = @"downloadPercentage";

@protocol TMPodcastEpisodeDelegate <NSObject>

@property (strong, nonatomic) NSString *downloadURLString;
@property (strong, nonatomic) NSNumber *duration;
@property (strong, nonatomic) NSNumber *episodeNumber;
@property (strong, nonatomic) NSString *fileLocation;
@property (strong, nonatomic) NSNumber *fileSize;
@property (strong, nonatomic) NSDate *publishDate;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSNumber *lastPlayLocation;
@property (strong, nonatomic) NSNumber *collectionId;
@property (strong, nonatomic) id<TMPodcastDelegate> podcast;

//This is a temporary hack to move download along.
@property (assign, nonatomic) float downloadPercentage;

@end