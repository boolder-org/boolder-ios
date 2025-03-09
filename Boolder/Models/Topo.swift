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
    let boulderId: Int?
    let position: Int?
    
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
    
    var orderedProblems: [Problem] {
        orderedProblemsWithoutVariants.flatMap {
            [$0] + $0.children
        }
    }
}

// MARK: SQLite
extension Topo {
    static let id = Expression<Int>("id")
    static let areaId = Expression<Int>("area_id")
    static let boulderId = Expression<Int?>("boulder_id")
    static let position = Expression<Int?>("position")
    
    static func load(id: Int) -> Topo? {
        do {
            let topos = Table("topos").filter(self.id == id)
            
            do {
                if let t = try SqliteStore.shared.db.pluck(topos) {
                    return Topo(id: t[self.id], areaId: t[areaId], boulderId: t[boulderId], position: t[position])
                }
                
                return nil
            }
            catch {
                print (error)
                return nil
            }
        }
    }
    
    var orderedProblemsWithoutVariants: [Problem] {
        let query = Table("lines")
            .filter(Line.topoId == self.id)

        do {
            let results = try SqliteStore.shared.db.prepare(query).map { l in
                Problem.load(id: l[Line.problemId])
            }
            
            return results.compactMap{$0}
                .filter { $0.topoId == self.id } // to avoid showing multi-lines problems (eg. traverses) that don't actually *start* on the same topo
                .filter { $0.parentId == nil }
                .sorted {
                    ($0.line?.firstPoint?.x ?? 1) < ($1.line?.firstPoint?.x ?? 1)
                }
//                .filter { $0.line?.coordinates != nil }
        }
        catch {
            print (error)
            return []
        }
    }
}
