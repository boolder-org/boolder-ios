//
//  Cluster.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/06/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import UIKit
import SQLite

struct Cluster : Identifiable {
    let id: Int
    let name: String
    let priority: Int
}

// MARK: SQLite
extension Cluster {
    static let id = Expression<Int>("id")
    static let name = Expression<String>("name")
    static let priority = Expression<Int>("priority")
    
    static func load(id: Int) -> Cluster? {
        
        let query = Table("clusters").filter(self.id == id)
        
        do {
            if let c = try SqliteStore.shared.db.pluck(query) {
                
                return Cluster(id: id, name: c[name], priority: c[priority])
            }
            
            return nil
        }
        catch {
            print (error)
            return nil
        }
    }
    
    var areas: [Area] {
        let areas = Table("areas")
            .filter(Area.clusterId == id)
            .order(Area.priority.asc)
        
        do {
            return try SqliteStore.shared.db.prepare(areas).map { area in
                Area.load(id: area[Area.id])
            }.compactMap{$0}
        }
        catch {
            print (error)
            return []
        }
    }
}
