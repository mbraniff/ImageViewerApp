//
//  ImgurImage.swift
//  ImageViewingApp
//
//  Created by Matthew Braniff on 5/8/26.
//

import Foundation

struct ImgurImage: Decodable {
    let id: String
    let title: String?
    let description: String?
    let type: String?
    let link: URL?
    
    enum CodingKeys: CodingKey {
        case id, title, description, type, link
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        let linkString = try container.decode(String.self, forKey: .link)
        self.link = URL(string: linkString)
    }
}

extension ImgurImage: Identifiable {}
