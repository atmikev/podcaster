//
//  NSManagedObject+EntityName.h
//  Podcaster
//
//  Created by Tyler Mikev on 4/24/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "NSManagedObject+EntityName.h"

@interface NSManagedObject (EntityName)

+ (NSString *)entityName;

@end
