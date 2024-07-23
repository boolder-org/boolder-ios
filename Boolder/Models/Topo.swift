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
        Downloader.onDiskFile(for: self)
    }
    
    var remoteFile: URL {
        URL(string: "https://d1tuum4k4qcbs8.cloudfront.net/proxy/topos/\(id)")!
    }
}
