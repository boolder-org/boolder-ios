//
//  Area.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 07/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import UIKit
import SQLite

struct Area : Identifiable {
    let id: Int
    let name: String
    let southWestLat: Double
    let southWestLon: Double
    let northEastLat: Double
    let northEastLon: Double
    
    static func load(id: Int) -> Area? {
        do {
            let db = SqliteStore.shared.db
            
            let areas = Table("areas").filter(Expression(literal: "id = '\(id)'"))
            
            let name = Expression<String>("name")
            let southWestLat = Expression<Double>("south_west_lat")
            let southWestLon = Expression<Double>("south_west_lon")
            let northEastLat = Expression<Double>("north_east_lat")
            let northEastLon = Expression<Double>("north_east_lon")
            
            do {
                if let a = try db.pluck(areas) {
                    return Area(id: id, name: a[name],
                                southWestLat: a[southWestLat], southWestLon: a[southWestLon],
                                northEastLat: a[northEastLat], northEastLon: a[northEastLon])
                }
                
                return nil
            }
            catch {
                print (error)
                return nil
            }
        }
    }
}

extension Area : Comparable {
    static func < (lhs: Area, rhs: Area) -> Bool {
        lhs.name < rhs.name
    }
}

extension Area : Hashable {
    static func == (lhs: Area, rhs: Area) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
