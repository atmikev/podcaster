//
//  TMDownloadManager.h
//  Podcaster
//
//  Created by Tyler Mikev on 3/8/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TMDownloadManager : NSObject

- (void)downloadPodcastAtURL:(NSURL *)downloadURL
                withFileName:(NSString *)fileName
                 updateBlock:(void (^)(CGFloat downloadPercentage))updateBlock
                successBlock:(void (^)(NSString *filePath))successBlock
             andFailureBlock:(void (^)(NSError *downloadError))failureBlock;

@end

