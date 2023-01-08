//
//  PoiRoute.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 08/01/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import SQLite

struct PoiRoute : Identifiable {
    let id: Int
    let areaId: Int
    let poiId: Int
    let distanceInMinutes: Int
    let transport: Transport
    
    enum Transport {
        case walking
        case bike
    }
    
    static func load(id: Int) -> PoiRoute? {
        do {
            let db = SqliteStore.shared.db
            
            let poiRoutes = Table("poi_routes")
            let _id = Expression<Int>("id")
            let areaId = Expression<Int>("area_id")
            let poiId = Expression<Int>("poi_id")
            let distanceInMinutes = Expression<Int>("distance_in_minutes")
            let transport = Expression<String>("transport")
            
            let query = poiRoutes.filter(_id == id)
            
            do {
                if let p = try db.pluck(query) {
                    return PoiRoute(id: id, areaId: p[areaId], poiId: p[poiId], distanceInMinutes: p[distanceInMinutes], transport: p[transport] == "bike" ? .bike : .walking)
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
