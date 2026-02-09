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

struct Topo: Hashable, Identifiable {
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
    
    var problems: [Problem] {
        let lines = Table("lines")
            .filter(Line.topoId == id)
        
        do {
            return try SqliteStore.shared.db.prepare(lines).map { l in
                Problem.load(id: l[Line.problemId])
            }
            .compactMap { $0 }
            .filter { $0.topoId == id }
            .filter { $0.line?.coordinates != nil }
        }
        catch {
            print(error)
            return []
        }
    }
    
    var topProblem: Problem? {
        problems.max { $0.zIndex < $1.zIndex }
    }
    
    var onSameBoulder: [Topo] {
        guard let boulderId = boulderId else { return [] }
        
        return Topo.onBoulder(boulderId)
    }
    
    static func onBoulder(_ id: Int) -> [Topo] {
        let query = Table("topos")
            .filter(Topo.boulderId == id)
            .order(Topo.position)
        
        do {
            return try SqliteStore.shared.db.prepare(query).map { t in
                Topo.load(id: t[Topo.id])! // FIXME: don't ue bang
            }
        }
        catch {
            print (error)
            return []
        }
    }
}
