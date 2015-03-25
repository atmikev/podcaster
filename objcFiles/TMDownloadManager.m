//
//  TMDownloadManager.m
//  Podcaster
//
//  Created by Tyler Mikev on 3/8/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMDownloadManager.h"

@interface TMDownloadManager ()<NSURLSessionDownloadDelegate>

@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSURLSessionDownloadTask *fileDownloadTask;
@property (strong, nonatomic) NSURLSession *session;
@property (copy, nonatomic) void(^updateBlock)(CGFloat percentage);
@property (copy, nonatomic) void(^successBlock)(NSString *filePath);
@property (copy, nonatomic) void(^failureBlock)(NSError *error);

@end

@implementation TMDownloadManager

- (void)downloadPodcastAtURL:(NSURL *)downloadURL
                withFileName:(NSString *)fileName
                 updateBlock:(void (^)(CGFloat downloadPercentage))updateBlock
                successBlock:(void (^)(NSString *filePath))successBlock
             andFailureBlock:(void (^)(NSError *downloadError))failureBlock {
    
    self.updateBlock = updateBlock;
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    self.fileName = fileName;
    
    NSURLSessionConfiguration *sessionConfig =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    
    sessionConfig.allowsCellularAccess = YES;
    sessionConfig.timeoutIntervalForRequest = 30.0;
    sessionConfig.timeoutIntervalForResource = 60.0 * 30;
    sessionConfig.HTTPMaximumConnectionsPerHost = 1;
    
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                          delegate:self
                                                     delegateQueue:nil];

    
    self.fileDownloadTask = [self.session downloadTaskWithURL:downloadURL];
    
    //fire it up
    [self.fileDownloadTask resume];
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    if (self.updateBlock) {
        //call our update block w/ the latest download percentage
        NSNumber *written = [NSNumber numberWithLongLong:totalBytesWritten];
        NSNumber *total = [NSNumber numberWithLongLong:totalBytesExpectedToWrite];
        CGFloat percentage = [written floatValue] / [total floatValue];
        self.updateBlock(percentage);
    }
    
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    if (error && self.failureBlock) {
        self.failureBlock(error);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error && self.failureBlock) {
        self.failureBlock(error);
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    //get the file, which is stored in a temp directory at 'location'
    NSError *fileReadingError;
    NSData *fileData = [NSData dataWithContentsOfURL:location options:0 error:&fileReadingError];

    if (fileReadingError && self.failureBlock) {
        //if we had an error reading the file, pass back an error
        self.failureBlock(fileReadingError);
    } else {

        //write the file to our Documents directory
        NSError *fileWritingError;
        NSString *savedFileLocation = [self saveData:fileData withFileName:self.fileName andError:fileWritingError];

        //tell the delegate we're done
        if (fileWritingError && self.failureBlock) {
            //if we failed, pass back the error
            self.failureBlock(fileWritingError);
        } else if (savedFileLocation && self.successBlock) {
            //otherwise pass back the file location
            self.successBlock(savedFileLocation);
        }
    }
    
}

- (NSString *)saveData:(NSData *)fileData
          withFileName:(NSString *)fileName
              andError:(NSError *)fileWritingError {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    //save file
    [fileData writeToFile:filePath options:0 error:&fileWritingError];

    return filePath;
}


@end
