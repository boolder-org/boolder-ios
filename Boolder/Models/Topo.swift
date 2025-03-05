//
//  Topo.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 15/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import Foundation
import UIKit
import SQLite

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
        URL(string: "https://assets.boolder.com/proxy/topos/\(id)")!
    }
}

// MARK: SQLite
extension Topo {
    var problemsWithoutVariants: [Problem] {
        let query = Table("lines")
            .filter(Line.topoId == self.id)

        do {
            let results = try SqliteStore.shared.db.prepare(query).map { l in
                Problem.load(id: l[Line.problemId])
            }
            
            return results.compactMap{$0}
                .filter { $0.topoId == self.id } // to avoid showing multi-lines problems (eg. traverses) that don't actually *start* on the same topo
                .filter { $0.parentId == nil }
//                .filter { $0.line?.coordinates != nil }
        }
        catch {
            print (error)
            return []
        }
    }
}
