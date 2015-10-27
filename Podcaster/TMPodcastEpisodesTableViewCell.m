//
//  TMPodcastEpisodesTableViewCell.m
//  Podcaster
//
//  Created by Tyler Mikev on 3/7/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMPodcastEpisodesTableViewCell.h"
#import "TMPodcastEpisode.h"
#import "NSString+Formatter.h"
#import "TMPodcastEpisodeProtocol.h"
#import "TMPodcastEpisodeDownloadDelegate.h"
#import <UAProgressView.h>

@interface TMPodcastEpisodesTableViewCell ()
@property (strong, nonatomic) UIImageView *downloadImageView;
@property (strong, nonatomic) UIImageView *deleteImageView;
@property (strong, nonatomic) UIImageView *cancelImageView;
@property (strong, nonatomic) UIImageView *downloadedImageView;
@property (copy, nonatomic) void(^startDownloadingBlock)(UAProgressView *progressView);
@property (copy, nonatomic) void(^stopDownloadingBlock)(UAProgressView *progressView);
@property (copy, nonatomic) void(^deleteDownloadBlock)(UAProgressView *progressView);
@end


@implementation TMPodcastEpisodesTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.preferredMaxLayoutWidth = 250;
    [self setupProgressView];
}

- (void)prepareForReuse {
    [self setEpisode:nil];
}

- (void)setEpisode:(NSObject<TMPodcastEpisodeDelegate> *)episode {
    
    //remove any old KVOs off the old episode
    @try {
        [_episode removeObserver:self forKeyPath:kDownloadPercentageKey];
    }
    @catch (NSException *exception) {
        //don't really need to do anything here
    }
    
    //set the new episode
    _episode = episode;
    
    //finish setting up
    self.titleLabel.text = episode.title;
    
    self.durationLabel.text = [NSString durationStringFromDuration:episode.duration];
    [self.durationLabel sizeToFit];
    
    self.publishDateLabel.text = [NSString publishDateStringFromPublishDate:episode.publishDate];
    
    if (episode.fileLocation) {
        [self setDownloadState:TMDownloadStateCompleted];
    } else if (episode.downloadPercentage > 0 && episode.downloadPercentage < 1) {
        [self setDownloadState:TMDownloadStateDownloading];
    } else {
        [self setDownloadState:TMDownloadStateNotDownloading];
    }
}

- (void)setupProgressView {
    //setup the stop button
    CGRect stopFrame = CGRectMake(0, 0, 12, 12);
    self.cancelImageView = [[UIImageView alloc] initWithFrame:stopFrame];
    self.cancelImageView.backgroundColor = [UIColor blackColor];

    //setup the stop button
    self.deleteImageView = [[UIImageView alloc] initWithFrame:stopFrame];
    self.deleteImageView.image = [UIImage imageNamed:@"deleteLight"];
    
    //setup the downloadButton
    CGRect downloadFrame = CGRectMake(0, 0, 15, 15);
    self.downloadImageView = [[UIImageView alloc] initWithFrame:downloadFrame];
    [self.downloadImageView setImage:[UIImage imageNamed:@"downloadArrow"]];
   
    //start out with the downloadButton as the centralView
    self.progressView.centralView = self.downloadImageView;
    
    //create callback blocks
    __weak typeof (self) weakSelf = self;
    self.startDownloadingBlock = ^(UAProgressView *progressView){
        [weakSelf startDownload];
    };
    self.stopDownloadingBlock = ^(UAProgressView *progressView){
        [weakSelf stopDownload];
    };
    self.deleteDownloadBlock = ^(UAProgressView *progressView){
        [weakSelf deleteDownload];
    };
    
    //set initial callback block
    self.progressView.didSelectBlock = self.startDownloadingBlock;
    
    self.progressView.fillOnTouch = NO;
}

- (void)setDownloadState:(TMDownloadState)downloadState {
    _downloadState = downloadState;
    
    switch (downloadState) {
        case TMDownloadStateNotDownloading:
            [self readyToDownloadState];
            break;
        case TMDownloadStateDownloading:
            [self downloadingState];
            break;
        case TMDownloadStateCompleted:
            [self completedDownloadState];
            break;
        default:
            break;
    }
}

- (void)updateProgressView:(CGFloat)progress {
    
    //WHY DOES THIS KEEP UPDATING IF WE'VE UNREGISTERED FROM THE OLD EPISODE!?!?!
    if (self.downloadState == TMDownloadStateDownloading) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress == 1) {
                [self setDownloadState:TMDownloadStateCompleted];
            }
            
            [self.progressView setProgress:progress];
        });
    }
}

- (void)downloadCompleted {
    [self completedDownloadState];
}

- (void)startDownload {
    [self.downloadDelegate startDownloadForEpisode:self.episode];
    [self setDownloadState:TMDownloadStateDownloading];
    
    //kvo the downloadPercentage for the episode
    [self.episode addObserver:self forKeyPath:kDownloadPercentageKey options:(NSKeyValueObservingOptionNew) context:nil];
}

- (void)stopDownload {
    [self.downloadDelegate stopDownloadForEpisode:self.episode];
    [self setDownloadState:TMDownloadStateNotDownloading];
}

- (void)deleteDownload {
    [self.downloadDelegate deleteDownloadForEpisode:self.episode];
    [self setDownloadState:TMDownloadStateNotDownloading];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kDownloadPercentageKey]) {
        NSNumber *downloadProgress = [change objectForKey:NSKeyValueChangeNewKey];
        [self updateProgressView:[downloadProgress floatValue]];
    }
}

#pragma mark - UI States

- (void)readyToDownloadState {
    [self.progressView setProgress:0];
    self.progressView.centralView = self.downloadImageView;
    self.progressView.didSelectBlock = self.startDownloadingBlock;
    [self.progressView unfill];
}

- (void)downloadingState {
    self.progressView.centralView = self.cancelImageView;
    self.progressView.didSelectBlock = self.stopDownloadingBlock;
    [self.progressView unfill];
    
    [self.episode addObserver:self
                   forKeyPath:kDownloadPercentageKey
                      options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial)
                      context:nil];
}

- (void)completedDownloadState {
    self.progressView.centralView = self.deleteImageView;
    self.progressView.didSelectBlock = self.deleteDownloadBlock;
    [self.progressView fill];
}

@end
