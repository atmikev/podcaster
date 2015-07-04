//
//  TMGenre.h
//  Podcaster
//
//  Created by Tyler Mikev on 6/14/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMGenre : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) NSArray *podcasts;

+ (instancetype)genreWithName:(NSString *)name andURL:(NSString *)urlString;

@end
