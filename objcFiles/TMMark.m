//
//  Mark.m
//  Podcaster
//
//  Created by Tyler Mikev on 2/7/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMMark.h"

@implementation TMMark

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.time = [[dictionary objectForKey:@"time"] doubleValue];
        self.imageLocation = [dictionary objectForKey:@"imageLocation"];
        self.link = [dictionary objectForKey:@"link"];
    }
    return self;
}

@end
