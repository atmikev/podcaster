//
//  TMPodcastsManager.m
//  Podcaster
//
//  Created by Tyler Mikev on 3/7/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMPodcastsManager.h"
#import "XMLReader.h"
#import "TMPodcastEpisode.h"
#import "TMDownloadManager.h"
#import "TMPodcast.h"
#import "TMPodcastsManager.h"
#import "TMiTunesResponse.h"

@interface TMPodcastsManager ()<NSXMLParserDelegate>

@property (strong, nonatomic) TMDownloadManager *downloadManager;

@end

@implementation TMPodcastsManager

- (void)topPodcastsWithSuccessBlock:(void(^)(NSArray *podcasts))successBlock
                    andFailureBlock:(void(^)(NSError *error))failureBlock {
    __weak TMPodcastsManager *weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"https://itunes.apple.com/search?term=npr&entity=podcast&limit=25"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error != nil && failureBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(error);
            });
        } else {
            
            if (data) {
                NSError *jsonError;
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if (jsonError != nil && failureBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        failureBlock(error);
                    });
                } else {
                    NSInteger resultCount = [[responseDictionary objectForKey:@"resultCount"] integerValue];
                    __block NSInteger finishedCount = 0;
                    NSArray *resultsDictionariesArray = [responseDictionary objectForKey:@"results"];
                    NSMutableArray *podcastsArray = [NSMutableArray new];
                    
                    for (NSDictionary *dictionary in resultsDictionariesArray) {
                        TMiTunesResponse *responseObject = [TMiTunesResponse iTunesResponseFromDictionary:dictionary];
                        NSString *urlString = responseObject.feedUrl.absoluteString;
                        [weakSelf podcastEpisodesAtURL:urlString withSuccessBlock:^(TMPodcast *podcast) {
                            [podcastsArray addObject:podcast];
                            finishedCount++;
                            if (finishedCount == resultCount && successBlock) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    successBlock(podcastsArray);
                                });
                            }
                        } andFailureBlock:^(NSError *error) {
                            finishedCount++;
                            if (failureBlock) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    failureBlock(error);
                                });
                            }
                            //if the last one failed, we still need to call the successBlock for any podcasts in the podcastsArray
                            if (finishedCount == resultCount && successBlock) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    successBlock(podcastsArray);
                                });
                            }
                        }];
                    }

                }
            }
            
        }
    }] resume];
}

- (void)podcastEpisodesAtURL:(NSString *)urlString
               withSuccessBlock:(void(^)(TMPodcast *podcast))successBlock
                andFailureBlock:(void(^)(NSError *error))failureBlock {
    
    //TMDownloadManager might be useful here, but for now its more for just downloading individual podcast episodes
    
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlString]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                //handle results
                if (error != nil) {
                    //uh oh, data failure
                    if (failureBlock) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            failureBlock(error);
                        });
                    }
                } else {
                    //no downloading error
                    NSError *xmlParserError;
                    //for some reason, if we pass in the raw data, the xml parser fails, so convert it to a string first
                    NSString *xmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSDictionary *podcastDictionary = [XMLReader dictionaryForXMLString:xmlString error:&xmlParserError];
                    TMPodcast *podcast = [TMPodcast initWithDictionary:podcastDictionary];
                    
                    if (xmlParserError || podcast.title == nil) {
                        //uh oh, xml parsing error
                        NSLog(@"Error parsing xml: %@",xmlParserError.localizedDescription);
                        if (failureBlock) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                failureBlock(xmlParserError);
                            });
                        }
                        
                    } else if (podcast) {
                        //sweet, lets roll

                        //parse the episodes out of the dictionary and into an array
                        if (successBlock && podcast.episodes.count > 0) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                successBlock(podcast);
                            });
                        }
                    } else {
                        if (failureBlock) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                failureBlock(nil);
                            });
                        }
                    }
                }
                
            }] resume];
}



- (void)downloadPodcastEpisodeAtURL:(NSURL *)episodeURL
                       withFileName:(NSString *)fileName
                        updateBlock:(void(^)(CGFloat downloadPercentage))updateBlock
                       successBlock:(void(^)(NSString *filePath))successBlock
                    andFailureBlock:(void(^)(NSError *error))failureBlock {
    
    if (self.downloadManager) {
#warning TODO: add ability to queue up multiple downloads
        return;
    }
    __weak TMPodcastsManager *weakSelf = self;
    self.downloadManager = [[TMDownloadManager alloc] init];
    [self.downloadManager downloadPodcastAtURL:episodeURL
                                  withFileName:fileName
                                   updateBlock:^(CGFloat downloadPercentage) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           if (updateBlock) {
                                               updateBlock(downloadPercentage);
                                           }
                                        });
                                   }
                                  successBlock:^(NSString *filePath) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          if (successBlock) {
                                              successBlock(filePath);
                                          }
                                          //once we're finished, nil out the downloadManager
                                          //so we can can start our next download when necessary
                                          weakSelf.downloadManager = nil;
                                      });
                                      
                                  }
                               andFailureBlock:^(NSError *downloadError) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if (failureBlock) {
                                           failureBlock(downloadError);
                                       }
                                       
                                       //once we're finished, nil out the downloadManager
                                       //so we can can start our next download when necessary
                                       weakSelf.downloadManager = nil;
                                   });
                               }
    ];
}



@end
