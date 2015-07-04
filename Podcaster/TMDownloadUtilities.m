//
//  TMDownloadManager.m
//  Podcaster
//
//  Created by Tyler Mikev on 3/8/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMDownloadUtilities.h"
#import "TMPodcast.h"

@interface TMDownloadUtilities ()<NSURLSessionDownloadDelegate>

@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSURLSessionDownloadTask *fileDownloadTask;
@property (strong, nonatomic) NSURLSession *session;
@property (copy, nonatomic) void(^updateBlock)(CGFloat percentage);
@property (copy, nonatomic) void(^successBlock)(NSString *filePath);
@property (copy, nonatomic) void(^failureBlock)(NSError *error);

@end

@implementation TMDownloadUtilities

+ (NSString *)saveData:(NSData *)fileData
          withFileName:(NSString *)fileName
              andError:(NSError *)fileWritingError {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    //save file
    [fileData writeToFile:filePath options:0 error:&fileWritingError];

    return fileName;
}

+ (void)downloadImageAtURL:(NSURL *)imageURL
            withCompletionBlock:(void(^)(UIImage *image))completionBlock {
    
    //download the image
    [[[NSURLSession sharedSession] dataTaskWithURL:imageURL
                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                     if (error) {
                                         NSLog(@"Error downloading podcast image: %@", error.debugDescription);
                                     } else if (data) {
                                         UIImage *image = [UIImage imageWithData:data];
                                         
                                         if (completionBlock) {
                                             completionBlock(image);
                                         }
                                         
                                     }
                                 }] resume];
    
}

+ (void)downloadImageForPodcast:(TMPodcast *)podcast
                        forCell:(UITableViewCell *)originalCell
                    atIndexPath:(NSIndexPath *)indexPath
                    inTableView:(UITableView *)tableView {
    
    [self downloadImageAtURL:podcast.imageURL withCompletionBlock:^(UIImage *image) {
        podcast.podcastImage = image;
        for (NSIndexPath *visibleIndexPath in [tableView indexPathsForVisibleRows]) {
            if ([visibleIndexPath isEqual:indexPath]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //reload the tableview
                    //(reloading a specific cell was causing a crash, but it was also not really unnecessary)
                    [tableView reloadData];
                });
                break;
            }
        }
    }];
    
}

@end
