//
//  NSManagedObject+EntityName.m
//  Podcaster
//
//  Created by Tyler Mikev on 4/24/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "NSManagedObject+EntityName.h"

@implementation NSManagedObject (EntityName)

+ (NSString *)entityName {
    return NSStringFromClass(self);
}

@end
