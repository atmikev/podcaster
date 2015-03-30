//
//  TMPodcastEpisode.h
//  Podcaster
//
//  Created by Tyler Mikev on 3/7/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMPodcastEpisode : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;
@property (strong, nonatomic) NSString *summary;
@property (strong, nonatomic) NSURL *episodeLinkURL;
@property (strong, nonatomic) NSString *episodeDescription;
@property (strong, nonatomic) NSDate *publishDate;
@property (strong, nonatomic) NSString *author;
@property (assign, nonatomic) NSInteger episodeNumber;
@property (assign, nonatomic) NSTimeInterval duration;
@property (strong, nonatomic) NSURL *downloadURL;
@property (assign, nonatomic) NSInteger fileSize;
@property (strong, nonatomic) NSURL *podcastURL;
@property (strong, nonatomic) NSString *fileLocation;

+ (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)episodesFromDictionariesArray:(NSArray *)dictionariesArray;

@end
