//
//  ImageRequestService.swift
//  ImageViewingApp
//
//  Created by Matthew Braniff on 5/8/26.
//

import Foundation

fileprivate let url = URL(string: "https://api.imgur.com/3/gallery/search/")!

class ImageRequestService {
    func getImages(_ search: String, _ sort: String, _ window: String, _ page: Int) async -> ImgurImageResponse? {
        let url = url
            .appending(path: sort)
            .appending(path: window)
            .appending(path: String(page))
        var request = URLRequest(url: url.appending(queryItems: [URLQueryItem(name: "q", value: search)]))
        request.addValue(Secrets.clientId, forHTTPHeaderField: "Authorization")
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
        
            print("Received Respons:\n\(String(data: data, encoding: .utf8) ?? "nil")")
            let decoder = JSONDecoder()
            return try decoder.decode(ImgurImageResponse.self, from: data)
        } catch let error as DecodingError {
            print("Failed to decode response: \(error.localizedDescription)")
        } catch let error {
            print("Failed to perform request: \(error.localizedDescription)")
        }
        return nil
    }
}
