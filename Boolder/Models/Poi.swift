//
//  Poi.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 09/05/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SQLite

struct Poi : Identifiable {
    let id: Int
    let type: PoiType
    let name: String
    let shortName: String
    let googleUrl: String
    
    enum PoiType {
        case parking
        case trainStation
        
        var string: String {
            switch self {
            case .parking:
                return "Parking"
            case .trainStation:
                return "Gare"
            }
        }
    }
    
    static let id = Expression<Int>("id")
    static let poiType = Expression<String>("poi_type")
    static let name = Expression<String>("name")
    static let shortName = Expression<String>("short_name")
    static let googleUrl = Expression<String>("google_url")
    
    static func load(id: Int) -> Poi? {
        let pois = Table("pois")
        
        let query = pois.filter(self.id == id)
        
        do {
            if let p = try SqliteStore.shared.db.pluck(query) {
                return Poi(
                    id: id,
                    type: p[poiType] == "train_station" ? .trainStation : .parking,
                    name: p[name],
                    shortName: p[shortName],
                    googleUrl: p[googleUrl]
                )
            }
            
            return nil
        }
        catch {
            print (error)
            return nil
        }
    }
    
    static var all: [Poi] {
        let query = Table("pois")
            .order(id.asc)
        
        do {
            return try SqliteStore.shared.db.prepare(query).map { poi in
                Poi.load(id: poi[id])
            }.compactMap{$0}
        }
        catch {
            print (error)
            return []
        }
    }
    
    var poiRoutes: [PoiRoute] {
        
        let poiId = Expression<Int>("poi_id") // FIXME: move to PoiRoute
        let distanceInMinutes = Expression<Int>("distance_in_minutes") // FIXME: move to PoiRoute
        
        let query = Table("poi_routes")
            .filter(poiId == self.id)
            .order(distanceInMinutes.asc)
        
        do {
            return try SqliteStore.shared.db.prepare(query).map { poiRoute in
                PoiRoute.load(id: poiRoute[PoiRoute.id])
            }.compactMap{$0}
        }
        catch {
            print (error)
            return []
        }
    }
}
