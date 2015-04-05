//
//  TMAudioPlayerViewController.h
//  Podcaster
//
//  Created by Tyler Mikev on 3/10/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMPodcastEpisode.h"

@interface TMAudioPlayerViewController : UIViewController

@property (strong, nonatomic) TMPodcastEpisode *episode;
@property (strong, nonatomic) UIImage *podcastImage;

@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIImageView *podcastImageView;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;
@property (weak, nonatomic) IBOutlet UILabel *timeElapsedLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeTotalLabel;

- (IBAction)playPause:(id)sender;
- (IBAction)timeSliderValueChanged:(id)sender;
@end
