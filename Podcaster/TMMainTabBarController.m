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

@interface TMMainTabBarController () <TMSelectPodcastEpisodeDelegate>

@property (strong, nonatomic) id selectedItem;


@end

@implementation TMMainTabBarController


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"VIEW DID LOAD CALLED FROM MAIN TAB BAR CONTROLLER");
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didSelectEpisode:(TMPodcastEpisode *)episode {
    NSLog(@"Delegate Called");
    self.selectedItem = episode;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil] ;
    TMAudioPlayerViewController *audioPlayerViewController = [storyboard instantiateViewControllerWithIdentifier:@"TMAudioPlayerViewController"];
    audioPlayerViewController.episode = episode;
    UINavigationController *mainNavController = self.viewControllers[0];
    [mainNavController pushViewController:audioPlayerViewController animated:true];
    //[self.viewControllers[0] presentViewController:audioPlayerViewController animated:true completion:nil];
    
}

-(void)presentAudioPlayer:(TMPodcastEpisode *)episode {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
