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
    let level1: Bool
    let level2: Bool
    let level3: Bool
    let level4: Bool
    let level5: Bool
    let level6: Bool
    let level7: Bool
    let southWestLat: Double
    let southWestLon: Double
    let northEastLat: Double
    let northEastLon: Double
    
    static func load(id: Int) -> Area? {
        do {
            let db = SqliteStore.shared.db
            
            let areas = Table("areas").filter(Expression(literal: "id = '\(id)'"))
            
            let name = Expression<String>("name")
            let level1 = Expression<Int>("level1")
            let level2 = Expression<Int>("level2")
            let level3 = Expression<Int>("level3")
            let level4 = Expression<Int>("level4")
            let level5 = Expression<Int>("level5")
            let level6 = Expression<Int>("level6")
            let level7 = Expression<Int>("level7")
            let southWestLat = Expression<Double>("south_west_lat")
            let southWestLon = Expression<Double>("south_west_lon")
            let northEastLat = Expression<Double>("north_east_lat")
            let northEastLon = Expression<Double>("north_east_lon")
            
            do {
                if let a = try db.pluck(areas) {
                    return Area(id: id, name: a[name],
                                level1: a[level1] == 1, level2: a[level2] == 1, level3: a[level3] == 1, level4: a[level4] == 1, level5: a[level5] == 1, level6: a[level6] == 1, level7: a[level7] == 1,
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
    
    var levels : [Int:Bool] {
        [
            1: level1,
            2: level2,
            3: level3,
            4: level4,
            5: level5,
            6: level6,
            7: level7,
        ]
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
