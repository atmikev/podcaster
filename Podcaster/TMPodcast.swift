//
//  TMPodcast.swift
//  Podcaster
//
//  Created by Tyler Mikev on 3/22/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

import Foundation

class TMPodcast {
    
    var title : String?
    var subtitle : String?
    var linkURLString : String?
    var podcastDescription : String?
    var language : String?
    var copyright: String?
    var author : String?
    var category : String?
    var imageURLString : String?
    var episodes : [TMPodcastEpisode]?
    
    init (dictionary : NSDictionary) {
        let podcastDictionary = JSON(dictionary)
        self.title = podcastDictionary["title"]["text"].string
        self.subtitle = podcastDictionary["itunes:subtitle"]["text"].string
        self.linkURLString = podcastDictionary["link"]["text"].string
        self.podcastDescription = podcastDictionary["description"]["text"].string
        self.language = podcastDictionary["language"]["text"].string
        self.copyright = podcastDictionary["copyright"]["text"].string
        self.author = podcastDictionary["itunes:author"]["text"].string
        self.category = podcastDictionary["itunes:category"]["text"].string
        self.imageURLString = podcastDictionary["itunes:image"]["href"].string
        self.episodes = self.episodesFromPodcastDictionary(podcastDictionary)
    }
    
    func episodesFromPodcastDictionary(podcastDictionary : JSON) -> [TMPodcastEpisode]? {
        var episodesElement = podcastDictionary["item"]
        var episodeDictionariesArray : [JSON]?
        
        //we need this to be in array form, so make sure this is an array of dictionaries
        if episodesElement.type == .Dictionary {
            episodeDictionariesArray = [episodesElement]
        } else if episodesElement.type == .Array {
            episodeDictionariesArray = episodesElement.array
        }
        
        var episodesArray : [TMPodcastEpisode]?
        if let episodeDictionariesArrayValue = episodeDictionariesArray? {
            for episodeDictionary in episodeDictionariesArrayValue {
                var episode = TMPodcastEpisode(episodeDictionary: episodeDictionary)
                
                if episodesArray == nil {
                    episodesArray = []
                }
                
                episodesArray?.append(episode)
            }
        }
        
        return episodesArray
    }

}