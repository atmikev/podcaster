//
//  TMPodcastProtocol.h
//  Podcaster
//
//  Created by Tyler Mikev on 4/25/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

@class UIImage;
@protocol TMPodcastDelegate <NSObject>

@property (strong, nonatomic) NSString *podcastDescription;
@property (strong, nonatomic) NSString *feedURLString;
@property (strong, nonatomic) UIImage *podcastImage;
@property (strong, nonatomic) NSSet *episodes;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSNumber *collectionId;

@end