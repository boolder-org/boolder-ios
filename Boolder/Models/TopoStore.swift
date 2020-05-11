//
//  TopoStore.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 09/05/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import Foundation

class TopoStore {
    var topoCollection = TopoCollection(topos: nil)
    
    private var areaId: Int
    
    init(areaId: Int) {
        self.areaId = areaId
        loadData()
    }
    
    private func loadData() {
        if let topojsonUrl = Bundle.main.url(forResource: "area-\(areaId)-topos", withExtension: "json") {
            do {
                let jsonData = try Data(contentsOf: topojsonUrl)
                topoCollection = try! JSONDecoder().decode(TopoCollection.self, from: jsonData)

            } catch {
                print("Error decoding topos json: \(error).")
            }
        }
    }
    
    
    struct TopoCollection: Decodable {
        let topos: [Topo]?
        
        func topo(withId id: Int) -> Topo? {
            return topos?.first(where: { topo in
                topo.id == id
            })
        }
    }
}
