//
//  TMAppilcation.m
//  Podcaster
//
//  Created by Tyler Mikev on 7/3/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMAppilcation.h"
#import "TMAudioPlayerManager.h"

@implementation TMAppilcation

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    
    if (event.type == UIEventTypeRemoteControl) {
        
        TMAudioPlayerManager *audioPlayerManager = [TMAudioPlayerManager sharedInstance];
        
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [audioPlayerManager togglePlayPause];
                break;
            case UIEventSubtypeRemoteControlPause:
                [audioPlayerManager pause];
                break;
            case UIEventSubtypeRemoteControlStop:
                [audioPlayerManager pause];
                break;
            case UIEventSubtypeRemoteControlPlay:
                [audioPlayerManager play];
                break;
            case UIEventSubtypeRemoteControlBeginSeekingForward:
                [audioPlayerManager startSeekingForwardContinuously];
                break;
            case UIEventSubtypeRemoteControlBeginSeekingBackward:
                [audioPlayerManager startSeekingBackwardContinuously];
                break;
            case UIEventSubtypeRemoteControlEndSeekingBackward:
                [audioPlayerManager stopSeekingContinuously];
                 break;
             case UIEventSubtypeRemoteControlEndSeekingForward:
                [audioPlayerManager stopSeekingContinuously];
              break;
            
            default:
                break;
        }
    }
}


@end
