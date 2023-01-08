//
//  Poi.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 09/05/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SQLite

struct Poi {
    let id: Int?
    let type: PoiType
    let name: String
    let googleUrl: String
    
    enum PoiType {
        case parking
        case trainStation
    }
    
    static func load(id: Int) -> Poi? {
        do {
            let db = SqliteStore.shared.db
            
            let pois = Table("pois")
            let _id = Expression<Int>("id")
            let poiType = Expression<String>("poi_type")
            let name = Expression<String>("name")
            let googleUrl = Expression<String>("google_rl")
            
            let query = pois.filter(_id == id)
            
            do {
                if let p = try db.pluck(query) {
                    return Poi(
                        id: id,
                        type: p[poiType] == "train_station" ? .trainStation : .parking,
                        name: p[name],
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
}
