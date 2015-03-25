//
//  TMPodcastEpisode.swift
//  Podcaster
//
//  Created by Tyler Mikev on 3/22/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

import Foundation

class TMPodcastEpisode {
    
    var title : String?
    var subtitle : String?
    var summary : String?
    var episodeLinkURLString : String?
    var episodeDescription : String?
    var publishDate : NSDate?
    var author : String?
    var episodeNumber : Int?
    var duration : Double?
    var downloadURLString : String?
    var fileSize : Int?
    var podcastURLString : String?
    var fileLocation : String?
    let dateFormat = "EE, d MMM yyy HH:m:ss ZZZ"
    
    init(episodeDictionary : JSON) {
        self.title = episodeDictionary["title"]["text"].string
        self.subtitle = episodeDictionary["itunes:subtitle"]["text"].string
        self.summary = episodeDictionary["itunes:summary"]["text"].string
        self.episodeLinkURLString = episodeDictionary["link"]["text"].string
        self.episodeDescription = episodeDictionary["description"]["text"].string

        if let dateString = episodeDictionary["pubDate"]["text"].string {
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = self.dateFormat;
            self.publishDate = dateFormatter.dateFromString(dateString)
        }
        
        self.author = episodeDictionary["itunes:author"]["text"].string
        self.episodeNumber = episodeDictionary["itunes:order"]["text"].int
        self.duration = episodeDictionary["itunes:duration"]["text"].double
        self.downloadURLString = episodeDictionary["enclosure"]["url"].string
        self.fileSize = episodeDictionary["enclosure"]["lenth"].int
        self.podcastURLString = episodeDictionary["feedburner:origLink"]["text"].string
    }
    
}