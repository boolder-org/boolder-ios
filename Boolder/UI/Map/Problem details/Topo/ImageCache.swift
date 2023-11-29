//
//  ImageCache.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 29/11/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import UIKit

class ImageCache {
    static let shared = ImageCache()
    private init() {}

    var cache = NSCache<NSURL, UIImage>()

    func getImage(url: URL) async throws -> UIImage? {
        // Check if the image is in the cache
        if let cachedImage = cache.object(forKey: url as NSURL) {
            return cachedImage
        }

        // Download the image if not in the cache
        let (data, _) = try await URLSession.shared.data(from: url)

        guard let image = UIImage(data: data) else {
            throw NSError(domain: "ImageErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey : "Failed to create image from data"])
        }

        // Cache the downloaded image
        cache.setObject(image, forKey: url as NSURL)

        return image
    }
}
