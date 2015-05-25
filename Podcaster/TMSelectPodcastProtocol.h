//
//  TMSelectPodcastProtocol.h
//  Podcaster
//
//  Created by Tyler Mikev on 5/23/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

@class TMPodcast;

@protocol TMSelectPodcastDelegate<NSObject>

- (void)didSelectPodcast:(TMPodcast *)podcast;

@end