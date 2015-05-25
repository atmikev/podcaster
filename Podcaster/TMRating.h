//
//  TMRating.h
//  Podcaster
//
//  Created by Tyler Mikev on 5/25/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface TMRating : PFObject<PFSubclassing>

@property (strong, nonatomic) NSString * comment;
@property (assign, nonatomic) NSInteger score;
@property (strong, nonatomic) NSString *episode;
@property (strong, nonatomic) NSString *podcast;
@property (assign, nonatomic) BOOL manualComment;
@property (strong, nonatomic) PFUser *user;
@property (assign, nonatomic) BOOL initiatedByUser;

@end
