//
//  TMPodcast.m
//  Podcaster
//
//  Created by Tyler Mikev on 3/7/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMPodcast.h"
#import "TMPodcastEpisode.h"

#import "TMiTunesResponse.h"

@implementation TMPodcast

+ (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    TMPodcast *podcast = [TMPodcast new];
    [podcast populateFromXMLDictionary:dictionary];
    
    return podcast;
}

+ (instancetype) initWithiTunesResponse:(TMiTunesResponse *)iTunesResponse {
    
    TMPodcast *podcast = [TMPodcast new];
    
    podcast.title = iTunesResponse.collectionName;
    podcast.linkURL = iTunesResponse.feedUrl;
    podcast.author = iTunesResponse.artistName;
    podcast.imageURL = iTunesResponse.artworkUrl100;

    return podcast;
}

- (void)populateFromXMLDictionary:(NSDictionary *)xmlDictionary {
    
    NSDictionary *podcastDictionary = xmlDictionary[@"rss"][@"channel"];
    
    self.title = podcastDictionary[@"title"][@"text"];
    self.linkURL = podcastDictionary[@"link"][@"text"];
    self.podcastDescription = podcastDictionary[@"description"][@"text"];
    self.language = podcastDictionary[@"language"][@"text"];
    self.copyright = podcastDictionary[@"copyright"][@"text"];
    self.author = podcastDictionary[@"itunes:author"][@"text"];
    self.subtitle = podcastDictionary[@"itunes:subtitle"][@"text"];
//    self.category = podcastDictionary[@"itunes:category"][@"text"];
    self.imageURL = [NSURL URLWithString:podcastDictionary[@"itunes:image"][@"href"]];
    
    self.episodes = [self episodesFromXMLDictionary:podcastDictionary];
}


- (NSArray *)episodesFromXMLDictionary:(NSDictionary *)xmlDictionary {
    id itemsElement = xmlDictionary[@"item"];
    NSArray *episodesArray = nil;
    
    if (itemsElement) {
        NSArray *itemsArray = nil;
        if (itemsElement) {
            if ([itemsElement isKindOfClass:[NSDictionary class]]) {
                itemsArray = @[itemsElement];
            } else if ([itemsElement isKindOfClass:[NSArray class]]) {
                itemsArray = itemsElement;
            }
        }
        
        episodesArray = [TMPodcastEpisode episodesFromDictionariesArray:itemsArray];
    }
   
    return episodesArray;
}



@end
