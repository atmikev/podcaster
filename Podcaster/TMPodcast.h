//
//  TMPodcast.h
//  Podcaster
//
//  Created by Tyler Mikev on 3/7/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TMPodcastProtocol.h"

@class TMiTunesResponse;

@interface TMPodcast : NSObject <TMPodcastDelegate>

@property (strong, nonatomic) NSString *subtitle;
@property (strong, nonatomic) NSString *language;
@property (strong, nonatomic) NSString *copyright;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSURL *image170URL;
@property (strong, nonatomic) NSURL *image600URL;
@property (strong, nonatomic) UIImage *podcastImage;
@property (strong, nonatomic) UIImage *podcast170Image;
@property (strong, nonatomic) UIImage *podcast600Image;
@property (strong, nonatomic) NSSet *episodes;
@property (strong, nonatomic) NSNumber *collectionId;

+ (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)initWithiTunesResponse:(TMiTunesResponse *)iTunesResponse;

@end
