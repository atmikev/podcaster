//
//  TMNavigationController.m
//  Podcaster
//
//  Created by Tyler Mikev on 5/3/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMNavigationController.h"

#import "TMReviewViewController.h"

@interface TMNavigationController ()

@property (strong, nonatomic) UIBarButtonItem *nowPlayingButton;

@end

@implementation TMNavigationController

- (void)setCurrentAudioPlayerViewController:(TMAudioPlayerViewController *)currentAudioPlayerViewController {
    _currentAudioPlayerViewController = currentAudioPlayerViewController;
    [self showNowPlayingButtonIfNecessaryOnViewController:currentAudioPlayerViewController];
}

- (BOOL)shouldShowNowPlayingOnViewController:(UIViewController *)viewController {
    return  self.currentAudioPlayerViewController != nil
            && self.currentAudioPlayerViewController != viewController
            && ![viewController isKindOfClass:[TMReviewViewController class]];
}

- (void)showNowPlayingButtonIfNecessaryOnViewController:(UIViewController *)viewController {

    if ([self shouldShowNowPlayingOnViewController:viewController]) {
        viewController.navigationItem.rightBarButtonItem = self.nowPlayingButton;
    } else {
        viewController.navigationItem.rightBarButtonItem = nil;
    }
}

- (UIBarButtonItem *)nowPlayingButton {
    if (!_nowPlayingButton) {
        _nowPlayingButton = [[UIBarButtonItem alloc] initWithTitle:@"Now Playing >"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(navigateToCurrentAudioPlayerViewController)];
    }
    return _nowPlayingButton;
}

- (void)navigateToCurrentAudioPlayerViewController {
    [self pushViewController:self.currentAudioPlayerViewController animated:YES];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self showNowPlayingButtonIfNecessaryOnViewController:viewController];
    [super pushViewController:viewController animated:animated];
    
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *viewController = [super popViewControllerAnimated:animated];
    [self showNowPlayingButtonIfNecessaryOnViewController:[self topViewController]];
    return viewController;
}



@end
