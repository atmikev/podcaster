//
//  TMiTunesResponse.h
//  Podcaster
//
//  Created by Tyler Mikev on 3/13/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMiTunesResponse : NSObject

@property (strong, nonatomic) NSString *wrapperType;
@property (strong, nonatomic) NSString *kind;
@property (assign, nonatomic) NSInteger artistId;
@property (assign, nonatomic) NSInteger collectionId;
@property (assign, nonatomic) NSInteger trackId;
@property (strong, nonatomic) NSString *artistName;
@property (strong, nonatomic) NSString *collectionName;
@property (strong, nonatomic) NSString *trackName;
@property (strong, nonatomic) NSString *collectionCensoredName;
@property (strong, nonatomic) NSString *trackCensoredName;
@property (strong, nonatomic) NSURL *artistViewUrl;
@property (strong, nonatomic) NSURL *collectionViewUrl;
@property (strong, nonatomic) NSURL *feedUrl;
@property (strong, nonatomic) NSURL *trackViewUrl;
@property (strong, nonatomic) NSURL *artworkUrl30;
@property (strong, nonatomic) NSURL *artworkUrl60;
@property (strong, nonatomic) NSURL *artworkUrl100;
@property (assign, nonatomic) NSInteger collectionPrice;
@property (assign, nonatomic) NSInteger trackPrice;
@property (assign, nonatomic) NSInteger trackRentalPrice;
@property (assign, nonatomic) NSInteger collectionHdPrice;
@property (assign, nonatomic) NSInteger trackHdPrice;
@property (assign, nonatomic) NSInteger trackHdRentalPrice;
@property (strong, nonatomic) NSDate *releaseDate;
@property (strong, nonatomic) NSString *collectionExplicitness;
@property (strong, nonatomic) NSString *trackExplicitness;
@property (assign, nonatomic) NSInteger trackCount;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *currency;
@property (strong, nonatomic) NSString *primaryGenreName;
@property (strong, nonatomic) NSURL *radioStationUrl;
@property (strong, nonatomic) NSURL *artworkUrl600;
@property (strong, nonatomic) NSArray *genreIds;
@property (strong, nonatomic) NSArray *genres;

+(instancetype)iTunesResponseFromDictionary:(NSDictionary *)dictionary;

@end
