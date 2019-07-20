//
//  PhotosResponse.swift
//  VirtualTourist
//
//  Created by Reem on 06/07/2019.
//  Copyright © 2019 Reem. All rights reserved.
//

import Foundation


struct PhotosResponse: Codable {
    var photos: Photos
}

struct Photos: Codable {
    var pages: Int
    var photo: [PhotoParser]
}

struct PhotoParser: Codable {
    
    var url: String?
    var title: String
    
    enum CodingKeys: String, CodingKey {
        case url = "url_m"
        case title
    }
}
