//
//  ImageQuery.swift
//  ImageViewingApp
//
//  Created by Matthew Braniff on 5/8/26.
//

import Foundation

struct ImageQuery: Decodable {
    let id: String
    let title: String
    let nsfw: Bool
    let images: [ImgurImage]?
}
