//
//  Secrets.swift
//  ImageViewingApp
//
//  Created by Matthew Braniff on 5/8/26.
//

import Foundation

enum Secrets {
    static func value(for key: String) -> String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let value = dict[key] as? String else {
            fatalError("Missing Secret: \(key)")
        }
        
        return value
    }
    
    static var clientId = value(for: "API_CLIENT_ID")
}
