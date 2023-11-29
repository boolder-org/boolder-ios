//
//  ImageCache.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 29/11/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import UIKit

class TopoImageCache {
    static let shared = TopoImageCache()
    private init() {}

    var cache = NSCache<NSNumber, UIImage>()
    
    struct Response: Codable {
        var url: String
    }

    func getImage(topoId: Int) async throws -> UIImage? {
        
        
        // Check if the image is in the cache
        if let cachedImage = cache.object(forKey: topoId as NSNumber) {
            return cachedImage
        }
        
        guard let url = URL(string: "https://www.boolder.com/api/v1/topos/\(topoId)") else {
            print("Invalid URL")
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
                let urlString = decodedResponse.url
                
                
                if let url = URL(string: urlString) {
                    
                    
                    // Download the image if not in the cache
                    let (data, _) = try await URLSession.shared.data(from: url)
                    
                    guard let image = UIImage(data: data) else {
                        throw NSError(domain: "ImageErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey : "Failed to create image from data"])
                    }
                    
                    // Cache the downloaded image
                    cache.setObject(image, forKey: topoId as NSNumber)
                    
                    return image
                }
            }
        }

        return nil
    }
}
