//
//  Cluster.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/06/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import UIKit
import SQLite

struct Cluster : Identifiable, Hashable {
    let id: Int
    let name: String
    let mainAreaId: Int
    
    // FIXME: remove hack
    var troisPignons : Bool {
        id == 2 || id == 3 || id == 4
    }
    
    static var troisPignons: [Cluster] {
        [
            Cluster.load(id: 4),
            Cluster.load(id: 2),
            Cluster.load(id: 3),
//            Cluster.load(id: 1)
        ].compactMap{$0}
    }
    
    var mainArea: Area {
        Area.load(id: mainAreaId)!
    }
    
    var areasSorted: [Area] {
        mainArea.otherAreasOnSameClusterSorted.map{$0.area}
    }
}

// MARK: SQLite
extension Cluster {
    static let id = Expression<Int>("id")
    static let name = Expression<String>("name")
    static let mainAreaId = Expression<Int>("main_area_id")
    
    static func load(id: Int) -> Cluster? {
        
        let query = Table("clusters").filter(self.id == id)
        
        do {
            if let c = try SqliteStore.shared.db.pluck(query) {
                
                return Cluster(id: id, name: c[name], mainAreaId: c[mainAreaId])
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
