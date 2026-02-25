//
//  TopoImageCache.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 15/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import UIKit

final class TopoImageCache {
    static let shared = TopoImageCache()

    private let cache = NSCache<NSNumber, UIImage>()

    private init() {
        cache.countLimit = 64
    }

    func cachedImage(for topoId: Int) -> UIImage? {
        cache.object(forKey: NSNumber(value: topoId))
    }

    func image(for topo: Topo) async -> UIImage? {
        if let cached = cachedImage(for: topo.id) {
            return cached
        }

        let topoId = topo.id
        let path = topo.onDiskFile.path
        let image = await Task.detached(priority: .userInitiated) { () -> UIImage? in
            guard let loaded = UIImage(contentsOfFile: path) else { return nil }
            if #available(iOS 15.0, *) {
                return loaded.preparingForDisplay() ?? loaded
            }
            return loaded
        }.value

        if let image {
            cache.setObject(image, forKey: NSNumber(value: topoId))
        }
        return image
    }

    func preload(topos: [Topo]) {
        Task(priority: .utility) {
            for topo in topos {
                _ = await image(for: topo)
            }
        }
    }
}
