//
//  TMiTunesResponse.m
//  Podcaster
//
//  Created by Tyler Mikev on 3/13/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

#import "TMiTunesResponse.h"

@implementation TMiTunesResponse

+ (instancetype)iTunesResponseFromDictionary:(NSDictionary *)dictionary {
    TMiTunesResponse *response = [TMiTunesResponse new];
    
    response.wrapperType = [dictionary objectForKey:@"wrapperType"];
    response.kind = [dictionary objectForKey:@"kind"];
    response.artistId = [[dictionary objectForKey:@"artistId"] integerValue];
    response.collectionId = [[dictionary objectForKey:@"collectionId"] integerValue];
    response.trackId = [[dictionary objectForKey:@"trackId"] integerValue];
    response.artistName = [dictionary objectForKey:@"artistName"];
    response.collectionName = [dictionary objectForKey:@"collectionName"];
    response.trackName = [dictionary objectForKey:@"trackName"];
    response.collectionCensoredName = [dictionary objectForKey:@"collectionCensoredName"];
    response.trackCensoredName = [dictionary objectForKey:@"trackCensoredName"];
    response.artistViewUrl = [NSURL URLWithString:[dictionary objectForKey:@"artistViewUrl"]];
    response.collectionViewUrl = [NSURL URLWithString:[dictionary objectForKey:@"collectionViewUrl"]];
    response.feedUrl = [NSURL URLWithString:[dictionary objectForKey:@"feedUrl"]];
    response.trackViewUrl = [NSURL URLWithString:[dictionary objectForKey:@"trackViewUrl"]];
    response.artworkUrl30 = [NSURL URLWithString:[dictionary objectForKey:@"artworkUrl30"]];
    response.artworkUrl60 = [NSURL URLWithString:[dictionary objectForKey:@"artworkUrl60"]];
    response.artworkUrl100 = [NSURL URLWithString:[dictionary objectForKey:@"artworkUrl100"]];
    response.collectionPrice = [[dictionary objectForKey:@"collectionPrice"] integerValue];
    response.trackPrice = [[dictionary objectForKey:@"trackPrice"] integerValue];
    response.trackRentalPrice = [[dictionary objectForKey:@"trackRentalPrice"] integerValue];
    response.collectionHdPrice = [[dictionary objectForKey:@"collectionHdPrice"] integerValue];
    response.trackHdPrice = [[dictionary objectForKey:@"trackHdPrice"] integerValue];
    response.trackHdRentalPrice = [[dictionary objectForKey:@"trackHdRentalPrice"] integerValue];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"YYYY-MM-DDThh:mm:ssZ" options:0 locale:[NSLocale systemLocale]];
    response.releaseDate = [dateFormatter dateFromString:[dictionary objectForKey:@"releaseDate"]];
    response.collectionExplicitness = [dictionary objectForKey:@"collectionExplicitness"];
    response.trackExplicitness = [dictionary objectForKey:@"trackExplicitness"];
    response.trackCount = [[dictionary objectForKey:@"trackCount"] integerValue];
    response.country = [dictionary objectForKey:@"country"];
    response.currency = [dictionary objectForKey:@"currency"];
    response.primaryGenreName = [dictionary objectForKey:@"primaryGenreName"];
    response.radioStationUrl = [NSURL URLWithString:[dictionary objectForKey:@"radioStationUrl"]];
    response.artworkUrl600 = [NSURL URLWithString:[dictionary objectForKey:@"artworkUrl600"]];
    response.genreIds = [dictionary objectForKey:@"genreIds"];
    response.genres = [dictionary objectForKey:@"genres"];
    
    return response;
}

@end
