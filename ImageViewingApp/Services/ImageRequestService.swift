//
//  ImageRequestService.swift
//  ImageViewingApp
//
//  Created by Matthew Braniff on 5/8/26.
//

import Foundation

fileprivate let url = URL(string: "https://api.imgur.com/3/gallery/search/")!

class ImageRequestService {
    func getImages(_ search: String) async -> ImgurImageResponse? {
        var request = URLRequest(url: url.appending(queryItems: [URLQueryItem(name: "q", value: search)]))
        request.addValue(Secrets.clientId, forHTTPHeaderField: "Authorization")
        guard let (data, _) = try? await URLSession.shared.data(for: request) else {
            print("Failed to make request: ", request)
            return nil
        }
        
        let decoder = JSONDecoder()
        return try? decoder.decode(ImgurImageResponse.self, from: data)
    }
}
