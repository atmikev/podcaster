//
//  TMDownloadOperation.m
//  Podcaster
//
//  Created by Tyler Mikev on 7/4/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMDownloadOperation.h"
#import "TMDownloadUtilities.h"

@interface TMDownloadOperation() <NSURLSessionDownloadDelegate>
@property (assign, nonatomic) BOOL isExecuting;
@property (assign, nonatomic) BOOL isFinished;
@property (strong, nonatomic) TMDownloadUtilities *downloadManager;
@property (strong, nonatomic, readwrite) NSString *downloadURLString;
@property (strong, nonatomic) NSString *fileName;
@property (copy, nonatomic) void(^updateBlock)(CGFloat percentage);
@property (copy, nonatomic) void(^successBlock)(NSString *filePath);
@property (copy, nonatomic) void(^failureBlock)(NSError *error);
@property (assign, nonatomic) CGFloat lastPercentage;
@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;
@end

@implementation TMDownloadOperation

- (instancetype)initWithDownloadURL:(NSString *)downloadURLString
               withFileName:(NSString *)fileName
                updateBlock:(void (^)(CGFloat))updateBlock
               successBlock:(void (^)(NSString *))successBlock
            andFailureBlock:(void (^)(NSError *))failureBlock {
    
    self = [super init];
    if (self) {
        _isFinished = NO;
        _isExecuting = NO;
        
        _downloadURLString = downloadURLString;
        _fileName = fileName;
        
        _updateBlock = updateBlock;
        _successBlock = successBlock;
        _failureBlock = failureBlock;
        _fileName = fileName;
        _lastPercentage = 0;
    }
    return self;
}

#pragma mark - NSOperation Overrides

- (void)start {
    [self bailIfCancelled];
    [self setIsExecuting:YES];
    [self startDownload];
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)setIsExecuting:(BOOL)isExecuting {
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = isExecuting;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setIsFinished:(BOOL)isFinished {
    [self willChangeValueForKey:@"isFinished"];
    _isFinished = isFinished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)bailIfCancelled {
    // Always check for cancellation before launching the task.
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self completeTask];
        return;
    }
}

- (void)cancel {
    [super cancel];
    
    //cancel the download
    [self.downloadTask cancel];
}

- (void)completeTask {
    [self setIsFinished:YES];
    [self setIsExecuting:NO];
}
#pragma mark - DownloadTask Methods

- (void)startDownload {
    
    NSURLSessionConfiguration *sessionConfig =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    
    sessionConfig.allowsCellularAccess = YES;
    sessionConfig.timeoutIntervalForRequest = 30.0;
    sessionConfig.timeoutIntervalForResource = 60.0 * 30;
    sessionConfig.HTTPMaximumConnectionsPerHost = 1;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                          delegate:self
                                                     delegateQueue:nil];
    
    //fire it up
    self.downloadTask = [session downloadTaskWithURL:[NSURL URLWithString:self.downloadURLString]];
    [self.downloadTask resume];
    
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    [self bailIfCancelled];
    
    if (self.updateBlock) {
        //call our update block w/ the latest download percentage
        NSNumber *written = [NSNumber numberWithLongLong:totalBytesWritten];
        NSNumber *total = [NSNumber numberWithLongLong:totalBytesExpectedToWrite];
        CGFloat percentage = [written floatValue] / [total floatValue];
        
        if (percentage - self.lastPercentage > 0.01 || percentage == 1.0) {
            //only update if we've gone atleast one percent higher.
            //this thing was popping off before and blocking the main UI thread because it was getting called so much
            self.lastPercentage = percentage;
            self.updateBlock(percentage);
        }
    }
    
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    if (error && self.failureBlock) {
        self.failureBlock(error);
    }
    
    [self completeTask];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error && self.failureBlock) {
        self.failureBlock(error);
    }
    
    [self completeTask];
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    [self bailIfCancelled];
    
    //get the file, which is stored in a temp directory at 'location'
    NSError *fileReadingError;
    NSData *fileData = [NSData dataWithContentsOfURL:location options:0 error:&fileReadingError];
    
    if (fileReadingError && self.failureBlock) {
        //if we had an error reading the file, pass back an error
        self.failureBlock(fileReadingError);
    } else {
        
        //write the file to our Documents directory
        NSError *fileWritingError;
        NSString *savedFileName = [TMDownloadUtilities saveData:fileData withFileName:self.fileName andError:fileWritingError];
        
        //tell the delegate we're done
        if (fileWritingError && self.failureBlock) {
            //if we failed, pass back the error
            self.failureBlock(fileWritingError);
        } else if (savedFileName && self.successBlock) {
            //otherwise pass back the file location
            self.successBlock(savedFileName);
        }
    }
    
    [self completeTask];
    
}


@end
