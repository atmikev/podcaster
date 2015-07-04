//
//  TMPodcastEpisode.h
//  Podcaster
//
//  Created by Tyler Mikev on 3/7/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMPodcastEpisodeProtocol.h"

@class TMPodcast;
@protocol TMPodcastDelegate;

@interface TMPodcastEpisode : NSObject <TMPodcastEpisodeDelegate>

@property (strong, nonatomic) id<TMPodcastDelegate> podcast;
@property (strong, nonatomic) NSString *subtitle;
@property (strong, nonatomic) NSString *summary;
@property (strong, nonatomic) NSString *episodeLinkURLString;
@property (strong, nonatomic) NSString *episodeDescription;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSString *podcastURLString;

+ (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (NSSet *)episodesFromDictionariesArray:(NSArray *)dictionariesArray forPodcast:(TMPodcast *)podcast;

@end
