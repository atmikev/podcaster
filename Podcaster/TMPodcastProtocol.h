//
//  TMPodcastProtocol.h
//  Podcaster
//
//  Created by Tyler Mikev on 4/25/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

@protocol TMPodcastDelegate <NSObject>

@property (strong, nonatomic) NSString *podcastDescription;
@property (strong, nonatomic) NSString *feedURLString;
@property (strong, nonatomic) UIImage *podcastImage;
@property (strong, nonatomic) NSArray *episodes;

@end