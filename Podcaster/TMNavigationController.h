//
//  TMNavigationController.h
//  Podcaster
//
//  Created by Tyler Mikev on 5/3/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMAudioPlayerViewController.h"

@interface TMNavigationController : UINavigationController

@property (strong, nonatomic) TMAudioPlayerViewController *currentAudioPlayerViewController;

@end
