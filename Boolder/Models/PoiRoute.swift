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
    
    // SQLite
    static let id = Expression<Int>("id")
    static let poiRoutes = Table("poi_routes")
    static let areaId = Expression<Int>("area_id")
    static let poiId = Expression<Int>("poi_id")
    static let distanceInMinutes = Expression<Int>("distance_in_minutes")
    static let transport = Expression<String>("transport")
    
    static func load(id: Int) -> PoiRoute? {
        
        let query = poiRoutes.filter(self.id == id)
        
        do {
            if let p = try SqliteStore.shared.db.pluck(query) {
                return PoiRoute(id: id, areaId: p[areaId], poiId: p[poiId], distanceInMinutes: p[distanceInMinutes], transport: p[transport] == "bike" ? .bike : .walking)
            }
            
            return nil
        }
        catch {
            print (error)
            return nil
        }
    }
    
    var poi: Poi? {
        let query = Table("pois").filter(Poi.id == self.poiId)
        
        do {
            if let poi = try SqliteStore.shared.db.pluck(query) {
                return Poi.load(id: poi[Poi.id])
            }
            
            return nil
        }
        catch {
            print (error)
            return nil
        }
    }
}
