//
//  TMMainTabBarController.h
//  Podcaster
//
//  Created by max blessen on 11/11/15.
//  Copyright © 2015 Tyler Mikev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMSelectPodcastEpisodeProtocol.h"

@interface TMMainTabBarController : UITabBarController <TMSelectPodcastEpisodeDelegate> 

-(void)didSelectEpisode:(TMPodcastEpisode *)episode;

@end
