//
//  Mark.h
//  Podcaster
//
//  Created by Tyler Mikev on 2/7/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMMark : NSObject

@property (assign, nonatomic) NSTimeInterval time;
@property (copy, nonatomic) NSString *imageLocation;
@property (copy, nonatomic) NSString *link;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
