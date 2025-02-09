//
//  Topo.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 19/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import UIKit
import SQLite

struct Line: Decodable {
    let id: Int
    let topoId: Int
    let coordinates: [PhotoPercentCoordinate]?
    
    struct PhotoPercentCoordinate: Decodable {
        let x: Double
        let y: Double
        
        func distance(to other: PhotoPercentCoordinate) -> Double {
            let dx = other.x - self.x
            let dy = other.y - self.y
            return (dx * dx + dy * dy).squareRoot()
        }
    }
    
    var firstPoint: Line.PhotoPercentCoordinate? {
        guard let firstPoint = coordinates?.first else { return nil }
        
        return firstPoint
    }
}

// MARK: SQLite
extension Line {
    static let id = Expression<Int>("id")
    static let problemId = Expression<Int>("problem_id")
    static let topoId = Expression<Int>("topo_id")
    static let coordinates = Expression<String>("coordinates")
    
    static func load(id: Int) -> Line? {
        do {
            let lines = Table("lines").filter(self.id == id)
            
            do {
                if let l = try SqliteStore.shared.db.pluck(lines) {
                    let jsonString = l[coordinates]
                    if let jsonData = jsonString.data(using: .utf8) {
                        let coordinates = try JSONDecoder().decode([Line.PhotoPercentCoordinate]?.self, from: jsonData)
                        
                        return Line(id: l[self.id], topoId: l[topoId], coordinates: coordinates)
                    }
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
