//
//  ImgurImageResponse.swift
//  ImageViewingApp
//
//  Created by Matthew Braniff on 5/8/26.
//

import Foundation

struct ImgurImageResponse: Decodable {
    var queries: [ImageQuery]
    
    enum CodingKeys: String, CodingKey {
        case queries = "data"
    }
}
