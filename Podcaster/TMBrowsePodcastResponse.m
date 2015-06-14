//
//  TMBrowsePodcastResponse.m
//  Podcaster
//
//  Created by Tyler Mikev on 6/14/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMBrowsePodcastResponse.h"

@implementation TMBrowsePodcastResponse

+ (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    TMBrowsePodcastResponse *response = [TMBrowsePodcastResponse new];
    response.name = dictionary[@"im:name"][@"label"];
    response.podcastID = dictionary[@"id"][@"attributes"][@"im:id"];
    
    //sort out the images
    NSArray *imagesArray = dictionary[@"im:image"];
    for (NSDictionary *imageDictionary in imagesArray) {
        NSString *attribute = imageDictionary[@"attributes"][@"height"];
        NSString *url = imageDictionary[@"label"];
        if ([attribute isEqualToString:@"55"]) {
            response.image55URL = url;
        } else if ([attribute isEqualToString:@"60"]) {
            response.image60URL = url;
        } else if ([attribute isEqualToString:@"170"]) {
            response.image170URL = url;
        }
    }
    
    return response;
}

@end
