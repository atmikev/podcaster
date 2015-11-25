//
//  TMMainTabBarController.h
//  Podcaster
//
//  Created by max blessen on 11/11/15.
//  Copyright © 2015 Tyler Mikev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMPodcastEpisode;
@protocol TMSelectPodcastEpisodeDelegate;

@interface TMMainTabBarController : UITabBarController <TMSelectPodcastEpisodeDelegate> 

-(void)didSelectEpisode:(TMPodcastEpisode *)episode;

-(void)setMainTabBarController:(TMMainTabBarController *)tabBarController;

+(instancetype)mainTabBarController;

@end
