//
//  Cluster.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/06/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import UIKit
import SQLite

import CoreLocation

struct Cluster : Identifiable, Hashable {
    let id: Int
    let name: String
    let mainAreaId: Int
    
    var mainArea: Area {
        Area.load(id: mainAreaId) ?? areas.first!
    }
    
    func areasSortedByDistance(_ reference: Area?) -> [Area] {
        let area = reference ?? mainArea
        
        return areas.sorted {
            $0.center.distance(from: area.center) < $1.center.distance(from: area.center)
        }
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
    
    static var all: [Cluster] {
        let query = Table("clusters").order(id)
        
        do {
            return try SqliteStore.shared.db.prepare(query).map { cluster in
                Cluster.load(id: cluster[id])
            }.compactMap{$0}
        }
        catch {
            print (error)
            return []
        }
    }
}
