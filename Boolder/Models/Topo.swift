//
//  Topo.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 15/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import Foundation
import UIKit

struct Topo: Hashable {
    let id: Int
    let areaId: Int
    
    init(id: Int, areaId: Int) {
        self.id = id
        self.areaId = areaId
    }
    
    var onDiskPhoto: UIImage? {
        UIImage(contentsOfFile: onDiskFile.path)
    }
    
    var onDiskPhotoExists: Bool {
        FileManager.default.fileExists(atPath: onDiskFile.path)
    }
    
    var onDiskFile: URL {
        onDiskFolder.appendingPathComponent("topo-\(id).jpg")
    }
    
    var onDiskFolder: URL {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return cachesURL.appendingPathComponent("topos").appendingPathComponent("area-\(areaId)")
    }
    
    var remoteFile: URL {
        URL(string: "https://d1tuum4k4qcbs8.cloudfront.net/proxy/topos/\(id)")!
    }
}
