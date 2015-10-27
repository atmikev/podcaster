//
//  TMCoreDataManager.h
//  Podcaster
//
//  Created by Tyler Mikev on 7/11/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

@interface TMCoreDataManager : NSObject

@property (strong, nonatomic, readonly) NSManagedObjectContext *mainThreadManagedObjectContext;

+ (instancetype)sharedInstance;

@end
