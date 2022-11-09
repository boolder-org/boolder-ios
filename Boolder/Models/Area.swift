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
    
    // FIXME: make return optional (the id we get might not exist: eg. area deleted)
    static func loadArea(id: Int) -> Area? {
        do {
            let db = SqliteStore.shared.db
            
            let areas = Table("areas").filter(Expression(literal: "id = '\(id)'"))
            
            let name = Expression<String?>("name") // FIXME: use optional?
            let southWestLat = Expression<Double?>("south_west_lat")
            let southWestLon = Expression<Double?>("south_west_lon")
            let northEastLat = Expression<Double?>("north_east_lat")
            let northEastLon = Expression<Double?>("north_east_lon")
            
            if let a = try! db.pluck(areas) {
                // print(p)
                
                return Area(id: id, name: a[name] ?? "",
                            southWestLat: a[southWestLat] ?? 0, southWestLon: a[southWestLon] ?? 0,
                            northEastLat: a[northEastLat] ?? 0, northEastLon: a[northEastLon] ?? 0)
            }
            
            return nil
        }
    }
}
