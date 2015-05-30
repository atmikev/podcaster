//
//  NSString+Formatter.h
//  Podcaster
//
//  Created by Tyler Mikev on 5/29/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Formatter)

+ (instancetype)durationStringFromDuration:(NSNumber *)duration;
+ (instancetype)publishDateStringFromPublishDate:(NSDate *)publishDate;

@end
