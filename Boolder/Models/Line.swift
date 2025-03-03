//
//  Topo.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 19/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import UIKit
import SwiftUI
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
    
    private var cgPoints: [CGPoint] {
        if let coordinates = coordinates {
            return coordinates.map{CGPoint(x: $0.x, y: $0.y)}
        }
        else {
            return []
        }
    }
    
    var path: Path {
//        guard problem.line != nil else { return Path() }
        guard cgPoints.count > 0 else { return Path() }
        
        let points = cgPoints
        let controlPoints = CubicCurveAlgorithm().controlPointsFromPoints(dataPoints: points)
        
        return Path { path in
            for i in 0..<points.count {
                let point = points[i]
                
                if i==0 {
                    path.move(to: CGPoint(x: point.x, y: point.y))
                } else {
                    let segment = controlPoints[i-1]
                    path.addCurve(to: point, control1: segment.controlPoint1, control2: segment.controlPoint2)
                }
            }
        }
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
