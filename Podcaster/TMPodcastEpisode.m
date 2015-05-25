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
    episode.episodeLinkURL = [NSURL URLWithString:dictionary[@"link"][@"text"]];
    episode.episodeDescription = dictionary[@"description"][@"text"];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss ZZZ"];
    episode.publishDate = [dateFormatter dateFromString:dictionary[@"pubDate"][@"text"]];
    
    episode.author = dictionary[@"itunes:author"][@"text"];
    episode.episodeNumber = [dictionary[@"itunes:order"][@"text"] integerValue];
    episode.duration = [dictionary[@"itunes:duration"][@"text"] doubleValue];

    NSDictionary *enclosure = dictionary[@"enclosure"];
    episode.downloadURL = [NSURL URLWithString:enclosure[@"url"]];
    episode.fileSize = [enclosure[@"length"] integerValue];
    
    episode.subtitle = dictionary[@"itunes:subtitle"][@"text"];
    episode.summary = dictionary[@"itunes:summary"][@"text"];
    episode.podcastURL = [NSURL URLWithString:dictionary[@"feedburner:origLink"][@"text"]];

    
    return episode;
}

- (BOOL)isEqual:(id)object {
    TMPodcastEpisode *episode = (TMPodcastEpisode *)object;
    BOOL isEqual = [self.downloadURL.absoluteString isEqualToString:episode.downloadURL.absoluteString];
    return isEqual;
}

- (NSString *)publishDateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM d, YYYY"];
    return [dateFormatter stringFromDate:self.publishDate];
}

- (NSString *)durationString {
    NSInteger minutes = self.duration / 60;
    return [NSString stringWithFormat:@"%ld min", (long)minutes];
}

@end
