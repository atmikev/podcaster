//
//  TMPodcastSubscriptionDelegate.h
//  Podcaster
//
//  Created by Tyler Mikev on 4/24/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

@class TMPodcast;

@protocol TMPodcastSubscriptionDelegate <NSObject>

- (void)subscribeToPodcast:(TMPodcast *)podcast;

@end
