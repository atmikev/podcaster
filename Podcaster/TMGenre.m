//
//  TMGenre.m
//  Podcaster
//
//  Created by Tyler Mikev on 6/14/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMGenre.h"

@implementation TMGenre

+ (instancetype)genreWithName:(NSString *)name andURL:(NSString *)urlString {
    TMGenre *genre = [TMGenre new];
    genre.name = name;
    genre.urlString = urlString;
    
    return genre;
}

@end
