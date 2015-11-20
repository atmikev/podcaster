//
//  TMDeeplink.m
//  Podcaster
//
//  Created by max blessen on 11/19/15.
//  Copyright © 2015 Tyler Mikev. All rights reserved.
//

#import "TMDeeplink.h"

@interface TMDeeplink ()

@end

@implementation TMDeeplink


+ (instancetype)initWithPodcastData:(NSNumber *)collectionId withEpisodeTitle:(NSString *)episodeTitle {
    TMDeeplink *deeplink = [TMDeeplink new];
    deeplink.podcastCollectionId = collectionId;
    deeplink.unencodedEpisodeTitle = episodeTitle;
    deeplink.encodedEpisodeTitle = [episodeTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    deeplink.deeplinkURL = [NSURL URLWithString:[NSString stringWithFormat:@"podcaster://%@/%@",collectionId, deeplink.encodedEpisodeTitle]];
    
    return deeplink;
}

-(void)shareDeeplink:(TMDeeplink *)deeplink withServiceType:(NSString *)serviceType withImage:(UIImage *)image withSuccessBlock:(void (^)(SLComposeViewController *))successBlock {
    SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:serviceType];
    [vc setInitialText: @"Check out this podcast!"];
    [vc addURL:deeplink.deeplinkURL];
    [vc addImage:image];
    successBlock(vc);
    
    
    
    
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
