//
//  TMPodcastEpisodeHeaderTableViewCell.m
//  Podcaster
//
//  Created by Tyler Mikev on 4/4/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMPodcastEpisodeHeaderTableViewCell.h"
#import "TMPodcast.h"
#import "TMSubscribedPodcast.h"
#import "TMPodcastProtocol.h"

static NSString * const kSubscribe = @"Subscribe";
static NSString * const kUnsubscribe = @"Unsubscribe";

typedef void(^UpdateSubscribeButtonBlock)(BOOL isSubscribed);

@interface TMPodcastEpisodeHeaderTableViewCell ()

@property (strong, nonatomic) id<TMPodcastDelegate> podcast;

@end

@implementation TMPodcastEpisodeHeaderTableViewCell

- (void)setupCellWithPodcast:(id<TMPodcastDelegate>)podcast {
    self.podcast = podcast;
    self.podcastImageView.image = podcast.podcastImage;
    self.titleLabel.text = podcast.title;
    self.descriptionTextView.text = podcast.podcastDescription;
    [self setupSubscribedButtonTitle];
}

- (void)setupSubscribedButtonTitle {
    NSString *buttonTitle = [self.podcast isKindOfClass:[TMSubscribedPodcast class]] ? kUnsubscribe : kSubscribe;
    [self.subscribeButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.preferredMaxLayoutWidth = 200;
    [super layoutSubviews];
}

- (void)subscribe {
    [self.subscriptionDelegate subscribeToPodcast:self.podcast
                              withCompletionBlock:[self updateSubscribedButtonTextForSubscribing:YES]];
}

- (void)unsubscribe {
    [self.subscriptionDelegate unsubscribeToPodcast:self.podcast
                                withCompletionBlock:[self updateSubscribedButtonTextForSubscribing:NO]];
}

- (UpdateSubscribeButtonBlock)updateSubscribedButtonTextForSubscribing:(BOOL)isSubscribing {
    
    UpdateSubscribeButtonBlock block = ^(BOOL wasSuccessful) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *title;
            
            if (isSubscribing) {
                title = wasSuccessful ? kUnsubscribe : kSubscribe;
            } else {
                title = wasSuccessful ? kSubscribe : kUnsubscribe;
            }

            [self.subscribeButton setTitle:title forState:UIControlStateNormal];
            
        });
    };
    
    return block;
}

#pragma mark - Button Handlers

- (IBAction)subscribeButtonHandler:(id)sender {
    
    //implement something more direct later
    if ([self.subscribeButton.titleLabel.text isEqualToString:kUnsubscribe]) {
        [self unsubscribe];
    } else {
        [self subscribe];
    }
}

@end
