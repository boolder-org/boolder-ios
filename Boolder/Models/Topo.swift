//
//  Topo.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 15/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import Foundation
import UIKit

struct Topo {
    let id: Int
    let areaId: Int
    let remoteFile: URL?
    
    init(id: Int, areaId: Int, remoteFile: URL? = nil) {
        self.id = id
        self.areaId = areaId
        self.remoteFile = remoteFile
    }
    
    // TODO: make private?
    var localFile: URL {
        let documentsURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return documentsURL.appendingPathComponent("area-\(areaId)").appendingPathComponent("topo-\(id).jpg")
    }
    
    var offlinePhoto: UIImage? {
        UIImage(contentsOfFile: localFile.path)
    }
}
