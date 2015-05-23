//
//  TMPodcastEpisode.h
//  Podcaster
//
//  Created by Tyler Mikev on 3/7/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMPodcast;
@protocol TMPodcastDelegate;

@interface TMPodcastEpisode : NSObject

@property (strong, nonatomic) id<TMPodcastDelegate> podcast;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;
@property (strong, nonatomic) NSString *summary;
@property (strong, nonatomic) NSURL *episodeLinkURL;
@property (strong, nonatomic) NSString *episodeDescription;
@property (strong, nonatomic) NSDate *publishDate;
@property (strong, nonatomic) NSString *publishDateString;
@property (strong, nonatomic) NSString *author;
@property (assign, nonatomic) NSInteger episodeNumber;
@property (assign, nonatomic) NSTimeInterval duration;
@property (strong, nonatomic) NSString *durationString;
@property (strong, nonatomic) NSURL *downloadURL;
@property (assign, nonatomic) NSInteger fileSize;
@property (strong, nonatomic) NSURL *podcastURL;
@property (strong, nonatomic) NSString *fileLocation;

+ (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (NSSet *)episodesFromDictionariesArray:(NSArray *)dictionariesArray forPodcast:(TMPodcast *)podcast;

@end
