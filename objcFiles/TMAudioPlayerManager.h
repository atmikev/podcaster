//
//  TMAudioPlayer.h
//  Podcaster
//
//  Created by Tyler Mikev on 3/6/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMMark;

@protocol TMAudioPlayerManagerDelegate <NSObject>

- (void)displayMark:(TMMark *)mark;

@end


@interface TMAudioPlayerManager : NSObject

@property (weak, nonatomic) id<TMAudioPlayerManagerDelegate> delegate;

- (instancetype)initWithDelegate:(id<TMAudioPlayerManagerDelegate>)delegate;

@end
