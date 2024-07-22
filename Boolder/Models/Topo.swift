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
    
    var offlinePhoto: UIImage? {
        UIImage(contentsOfFile: localFile.path)
    }
    
    var offlinePhotoExists: Bool {
        FileManager.default.fileExists(atPath: localFile.path)
    }
    
    private var localFile: URL {
        let documentsURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return documentsURL.appendingPathComponent("area-\(areaId)").appendingPathComponent("topo-\(id).jpg")
    }
    
    var remoteFile: URL {
        URL(string: "https://assets.boolder.com/proxy/topos/\(id)")!
    }
}
