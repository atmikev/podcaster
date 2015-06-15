//
//  TMBrowsePodcastResponse.h
//  Podcaster
//
//  Created by Tyler Mikev on 6/14/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMBrowsePodcastResponse : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *podcastID;
@property (strong, nonatomic) NSString *image55URLString;
@property (strong, nonatomic) NSString *image60URLString;
@property (strong, nonatomic) NSString *image170URLString;

+ (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
