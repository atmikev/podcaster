//
//  TMPodcastEpisode.m
//  Podcaster
//
//  Created by Tyler Mikev on 3/7/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMPodcastEpisode.h"
#import "TMPodcast.h"
#import "TMPodcastProtocol.h"

@implementation TMPodcastEpisode

@synthesize fileSize;
@synthesize downloadURLString;
@synthesize duration;
@synthesize episodeNumber;
@synthesize fileLocation;
@synthesize publishDate;
@synthesize title;
@synthesize lastPlayLocation;
@synthesize downloadPercentage;


+ (NSSet *)episodesFromDictionariesArray:(NSArray *)dictionariesArray forPodcast:(TMPodcast *)podcast {
    
    NSMutableSet *episodesArray = [NSMutableSet new];
    
    for (NSDictionary *dictionary in dictionariesArray) {
        TMPodcastEpisode *episode = [self initWithDictionary:dictionary];
        episode.podcast = podcast;
        [episodesArray addObject:episode];
    }
    
    return [episodesArray copy];
    
}

+ (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    TMPodcastEpisode *episode = [TMPodcastEpisode new];
    
    episode.title = dictionary[@"title"][@"text"];
    episode.episodeLinkURLString = dictionary[@"link"][@"text"];
    episode.episodeDescription = dictionary[@"description"][@"text"];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss ZZZ"];
    episode.publishDate = [dateFormatter dateFromString:dictionary[@"pubDate"][@"text"]];
    
    episode.author = dictionary[@"itunes:author"][@"text"];
    episode.episodeNumber = [NSNumber numberWithInteger:[dictionary[@"itunes:order"][@"text"] integerValue]];

    NSString *durationString = dictionary[@"itunes:duration"][@"text"];
    episode.duration = [self durationFromDurationString:durationString];

    NSDictionary *enclosure = dictionary[@"enclosure"];
    episode.downloadURLString = enclosure[@"url"];
    episode.fileSize = [NSNumber numberWithInteger:[enclosure[@"length"] integerValue]];
    
    episode.subtitle = dictionary[@"itunes:subtitle"][@"text"];
    episode.summary = dictionary[@"itunes:summary"][@"text"];
    episode.podcastURLString = dictionary[@"feedburner:origLink"][@"text"];

    return episode;
}

+ (NSNumber *)durationFromDurationString:(NSString *)durationString {
    //this can come back as in hh:mm:ss, mm:ss, or as the total number of seconds, so use a scanner to differentiate. idiots.
    
    //reverse the string so we start with seconds
    NSTimeInterval duration = 0;
    if ([durationString containsString:@":"]) {
        NSInteger secondsMultiplier = 1;
        NSArray *timeSubstrings = [durationString componentsSeparatedByString:@":"];
        NSArray *reversedTimeSubstrings = [[timeSubstrings reverseObjectEnumerator] allObjects];
        for (NSString *substring in reversedTimeSubstrings) {
            duration += [substring doubleValue] *secondsMultiplier;
            
            //take the seconds multiplier up by a factor of 60 so it converts the value to seconds properly
            secondsMultiplier *= 60;
        }
    } else {
        duration = [durationString integerValue];
    }

    return [NSNumber numberWithDouble:duration];
}

- (BOOL)isEqual:(id)object {
    TMPodcastEpisode *episode = (TMPodcastEpisode *)object;
    BOOL isEqual = [self.downloadURLString isEqualToString:episode.downloadURLString];
    return isEqual;
}

@end
