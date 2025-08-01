//
//  Poi.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 09/05/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SQLite
import CoreLocation

struct Poi : Identifiable {
    let id: Int
    let type: PoiType
    let name: String
    let shortName: String
    let googleUrl: String
    let coordinate: CLLocationCoordinate2D
    
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
}

// MARK: SQLite
extension Poi {
    static let id = Expression<Int>("id")
    static let poiType = Expression<String>("poi_type")
    static let name = Expression<String>("name")
    static let shortName = Expression<String>("short_name")
    static let googleUrl = Expression<String>("google_url")
    static let latitude = Expression<Double>("latitude")
    static let longitude = Expression<Double>("longitude")
    
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
                    googleUrl: p[googleUrl],
                    coordinate: CLLocationCoordinate2D(latitude: p[latitude], longitude: p[longitude])
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
        let query = Table("poi_routes")
            .filter(PoiRoute.poiId == self.id)
            .order(PoiRoute.distanceInMinutes.asc)
        
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
