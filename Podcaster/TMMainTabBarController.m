//
//  TMMainTabBarController.m
//  Podcaster
//
//  Created by max blessen on 11/11/15.
//  Copyright © 2015 Tyler Mikev. All rights reserved.
//

#import "TMMainTabBarController.h"
#import "TMSelectPodcastEpisodeProtocol.h"
#import "TMPodcastEpisode.h"
#import "TMPodcast.h"
#import "TMAudioPlayerViewController.h"

@interface TMMainTabBarController () <UINavigationControllerDelegate>

@property (strong, nonatomic) id selectedItem;

@end

@implementation TMMainTabBarController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didSelectEpisode:(TMPodcastEpisode *)episode {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil] ;
    TMAudioPlayerViewController *audioPlayerViewController = [storyboard instantiateViewControllerWithIdentifier:@"TMAudioPlayerViewController"];
    
    audioPlayerViewController.episode = episode;
    
    UINavigationController *mainNavController = self.viewControllers[0];
    [mainNavController pushViewController:audioPlayerViewController animated:true];
    
}

-(void)setMainTabBarController:(TMMainTabBarController *)tabBarController {
    
}

+(instancetype)mainTabBarController {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    TMMainTabBarController *tabBarController = [storyboard instantiateInitialViewController];
    
    return tabBarController;
}

@end
