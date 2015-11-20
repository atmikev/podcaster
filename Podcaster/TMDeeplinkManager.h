//
//  TMDeeplinkManager.h
//  Podcaster
//
//  Created by max blessen on 11/11/15.
//  Copyright © 2015 Tyler Mikev. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol TMSelectPodcastEpisodeDelegate;
@protocol TMPodcastDelegate;

@interface TMDeeplinkManager : NSObject

- (instancetype)initWithDelegate:(id<TMSelectPodcastEpisodeDelegate>)delegate;

- (void)searchForPodcast:(NSNumber *)collectionId
               forTitle:(NSString *)title;

+ (void)searchForPodcastWithCollectionID:(NSNumber *)collectionID
                                   title:(NSString *)title
                             andDelegate:(id<TMSelectPodcastEpisodeDelegate>)delegate;

@end