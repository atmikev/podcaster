//
//  TMPodcastSubscriptionDelegate.h
//  Podcaster
//
//  Created by Tyler Mikev on 4/24/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

@protocol TMPodcastDelegate;

@protocol TMPodcastSubscriptionDelegate <NSObject>

- (void)subscribeToPodcast:(id<TMPodcastDelegate>)podcast
       withCompletionBlock:(void(^)(BOOL wasSuccessful))completionBlock;

- (void)unsubscribeToPodcast:(id<TMPodcastDelegate>)podcast
         withCompletionBlock:(void(^)(BOOL wasSuccessful))completionBlock;

@end
