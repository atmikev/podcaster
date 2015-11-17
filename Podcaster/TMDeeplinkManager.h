//
//  TMDeeplinkManager.h
//  Podcaster
//
//  Created by max blessen on 11/11/15.
//  Copyright © 2015 Tyler Mikev. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TMPodcastProtocol.h"

@protocol TMSelectPodcastEpisodeDelegate;

@interface TMDeeplinkManager : NSObject

@property (strong, nonatomic) id<TMPodcastDelegate> podcast;
@property (weak, nonatomic) id<TMSelectPodcastEpisodeDelegate> delegate;

-(void)searchForPodcast:(NSNumber *)collectionId forTitle:(NSString *)title;


@end