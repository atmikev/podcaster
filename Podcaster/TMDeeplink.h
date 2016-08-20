//
//  TMDeeplink.h
//  Podcaster
//
//  Created by max blessen on 11/19/15.
//  Copyright © 2015 Tyler Mikev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLComposeViewController;

@interface TMDeeplink : NSObject

@property (strong, nonatomic) NSNumber *podcastCollectionId;
@property (strong, nonatomic) NSString *unencodedEpisodeTitle;
@property (strong, nonatomic) NSString *encodedEpisodeTitle;
@property (strong, nonatomic) NSURL *deeplinkURL;
@property (strong, nonatomic) SLComposeViewController *shareViewController;


+ (instancetype)initWithPodcastData:(NSNumber *)collectionId
                   withEpisodeTitle:(NSString *)episodeTitle;

-(void)shareDeeplink:(TMDeeplink *)deeplink
     withServiceType:(NSString *)serviceType
           withImage:(UIImage *)image
    withCompletionBlock:(void(^)(SLComposeViewController *viewController))completionBlock;

@end
