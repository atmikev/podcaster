//
//  TMDeeplink.m
//  Podcaster
//
//  Created by max blessen on 11/19/15.
//  Copyright © 2015 Tyler Mikev. All rights reserved.
//

#import "TMDeeplink.h"
#import <Social/Social.h>

@implementation TMDeeplink


+ (instancetype)initWithPodcastData:(NSNumber *)collectionId
                   withEpisodeTitle:(NSString *)episodeTitle {
    
    TMDeeplink *deeplink = [TMDeeplink new];
    
    deeplink.podcastCollectionId = collectionId;
    deeplink.unencodedEpisodeTitle = episodeTitle;
    deeplink.encodedEpisodeTitle = [episodeTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    deeplink.deeplinkURL = [NSURL URLWithString:[NSString stringWithFormat:@"podcaster://%@/%@",collectionId, deeplink.encodedEpisodeTitle]];
    
    return deeplink;
}

-(void)shareDeeplink:(TMDeeplink *)deeplink
     withServiceType:(NSString *)serviceType
           withImage:(UIImage *)image
 withCompletionBlock:(void (^)(SLComposeViewController *))completionBlock {
    
        SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:serviceType];
    
        [vc setInitialText: @"Check out this podcast!"];
        [vc addURL:deeplink.deeplinkURL];
        [vc addImage:image];
   
    if (completionBlock) {
        completionBlock(vc);
    }
    
}

@end
