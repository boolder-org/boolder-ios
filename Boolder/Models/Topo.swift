//
//  Topo.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 15/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import Foundation

struct Topo {
    let id: Int
    let areaId: Int
    let remoteFile: URL
    
    var localFile : URL {
        let documentsURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return documentsURL.appendingPathComponent("area-\(areaId)").appendingPathComponent("topo-\(id).jpg")
    }
}
