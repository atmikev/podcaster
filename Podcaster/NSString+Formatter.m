//
//  NSString+Formatter.m
//  Podcaster
//
//  Created by Tyler Mikev on 5/29/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "NSString+Formatter.h"

@implementation NSString (Formatter)

+ (instancetype)durationStringFromDuration:(NSNumber *)duration {
    NSInteger minutes = [duration integerValue] / 60;
    return [NSString stringWithFormat:@"%ld min", (long)minutes];
}

+ (instancetype)publishDateStringFromPublishDate:(NSDate *)publishDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM d, YYYY"];
    return [dateFormatter stringFromDate:publishDate];
}
@end
