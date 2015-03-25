//
//  TMPodcastTableViewCell.h
//  Podcaster
//
//  Created by Tyler Mikev on 3/13/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMPodcastTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *podcastImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
