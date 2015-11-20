//
//  AppDelegate.m
//  Podcaster
//
//  Created by Tyler Mikev on 2/7/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "TMAudioPlayerManager.h"
#import "TMAudioPlayerViewController.h"
#import "TMPodcast.h"
#import "TMPodcastEpisode.h"
#import "TMDeeplinkManager.h"
#import "TMMainTabBarController.h"

@interface AppDelegate ()

@property (strong, nonatomic) TMAudioPlayerViewController *audioPlayerViewController;
@property (strong, nonatomic) NSArray *episodes;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {

    NSNumber *collectionId = [url host];
    NSString *episodeTitle = [NSString stringWithFormat:@"%@", [url lastPathComponent]];
    
    [TMDeeplinkManager searchForPodcastWithCollectionID:collectionId
                                                  title:episodeTitle
                                            andDelegate:self.mainTabController];
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setWindowAndMainController];
    
    [self setupAudioSession];
    
    [self setupNavBarAttributes];
    
    // Initialize Parse.
    #warning Add parse key in
    NSAssert(YES,@"You need to add in your own parse keys");
    [Parse setApplicationId:nil
                  clientKey:nil];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptionsInBackground:launchOptions block:^(BOOL succeeded, NSError *PF_NULLABLE_S error) {
        if (!succeeded) {
            NSLog(@"Failed to send app open event to Parse:\n%@",error.localizedDescription);
        }
    }];
    
    
    //turn on the automatic user
    [PFUser enableAutomaticUser];
    [[PFUser currentUser] incrementKey:@"RunCount"];
    [[PFUser currentUser] saveInBackground];
    
    return YES;
}

-(void)setWindowAndMainController {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.audioPlayerViewController = [storyboard instantiateViewControllerWithIdentifier:@"TMAudioPlayerViewController"];
    self.mainTabController = [storyboard instantiateViewControllerWithIdentifier:@"mainTabController"];
    self.window.rootViewController = self.mainTabController;
    [self.window makeKeyAndVisible];
}

- (void)setupAudioSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if (!success) {
        NSLog(@"Error: Failed to set up audioSession");
    }
    
    NSError *activationError = nil;
    success = [audioSession setActive:YES error:&activationError];
    if (!success) {
        NSLog(@"Error: Failed to activate audio session");
    }

}

#pragma nav bar setup
- (void)setupNavBarAttributes {
    
    //white status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //set tint color for navbar
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{NSFontAttributeName :[UIFont fontWithName:@"HelveticaNeue-Thin" size:17],
       NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

@end
