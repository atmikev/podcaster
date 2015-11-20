//
//  AppDelegate.h
//  Podcaster
//
//  Created by Tyler Mikev on 2/7/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "TMPodcastProtocol.h"

@class TMMainTabBarController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) TMMainTabBarController *mainTabController;
@property (strong, nonatomic) id<TMPodcastDelegate> podcast;

@end

