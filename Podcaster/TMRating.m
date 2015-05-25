//
//  TMRating.m
//  Podcaster
//
//  Created by Tyler Mikev on 5/25/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMRating.h"

@implementation TMRating

@dynamic comment;
@dynamic score;
@dynamic episode;
@dynamic podcast;
@dynamic manualComment;
@dynamic user;
@dynamic initiatedByUser;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    //class name in Parse is Rating, not TMRating
    return @"Rating";
}

@end
