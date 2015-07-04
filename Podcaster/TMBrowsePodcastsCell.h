//
//  TMBrowsePodcastsCell.h
//  Podcaster
//
//  Created by Tyler Mikev on 6/13/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString * const kTMBrowsePodcastsCellIdentifier;

@interface TMBrowsePodcastsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
