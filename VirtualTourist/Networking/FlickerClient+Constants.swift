//
//  FlickerClient+Constants.swift
//  VirtualTourist
//
//  Created by Reem on 05/07/2019.
//  Copyright © 2019 Reem. All rights reserved.
//

import Foundation

extension FlickerClient {
    
    
    // MARK: - Flickr Basic Information
    
    struct Base {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
        static let SearchBBoxHalfWidth = 0.2
        static let SearchBBoxHalfHeight = 0.2
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
    
    // MARK: - Flickr Parameter Keys
    struct ParametersKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let BoundingBox = "bbox"
        static let PhotosPerPage = "per_page"
        static let Accuracy = "accuracy"
        static let Page = "page"
    }
    
    // MARK: - Flickr Parameter Values
    struct ParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "FLICKR_API_KEY_HERE"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
        static let PhotosPerPage = 12
        static let AccuracyCityLevel = "11"
        static let AccuracyStreetLevel = "16"
    }
}
