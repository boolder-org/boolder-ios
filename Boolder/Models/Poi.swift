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
    
    static func load(id: Int) -> Poi? {
        do {
            let db = SqliteStore.shared.db
            
            let pois = Table("pois")
            let _id = Expression<Int>("id")
            let poiType = Expression<String>("poi_type")
            let name = Expression<String>("name")
            let shortName = Expression<String>("short_name")
            let googleUrl = Expression<String>("google_url")
            
            let query = pois.filter(_id == id)
            
            do {
                if let p = try db.pluck(query) {
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
    }
    
    static var all: [Poi] {
        let db = SqliteStore.shared.db

        let id = Expression<Int>("id")
        
        let query = Table("pois")
            .order(id.asc)
        
        do {
            return try db.prepare(query).map { poi in
                Poi.load(id: poi[id])
            }.compactMap{$0}
        }
        catch {
            print (error)
            return []
        }
    }
    
    var poiRoutes: [PoiRoute] {
        let db = SqliteStore.shared.db

        let id = Expression<Int>("id")
        let poiId = Expression<Int>("poi_id")
        let distanceInMinutes = Expression<Int>("distance_in_minutes")
        
        let query = Table("poi_routes").filter(poiId == self.id).order(distanceInMinutes.asc)
        
        do {
            return try db.prepare(query).map { poiRoute in
                PoiRoute.load(id: poiRoute[id])
            }.compactMap{$0}
        }
        catch {
            print (error)
            return []
        }
    }
}
