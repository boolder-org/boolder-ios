//
//  Steepness.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 03/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

class Steepness  {
    enum SteepnessType: CaseIterable {
        case wall
        case slab
        case overhang
        case roof
        case traverse
        case unknown
    }
    
    let type: SteepnessType
    
    init(_ type: SteepnessType) {
        self.type = type
    }
    
    init(string: String) {
        switch string {
        case "wall":
            self.type = .wall
        case "slab":
            self.type = .slab
        case "overhang":
            self.type = .overhang
        case "roof":
            self.type = .roof
        case "traverse":
            self.type = .traverse
        case "unknown":
            self.type = .unknown
        default:
            // FIXME: add warning
            self.type = .unknown
        }
    }
    
    var name: String {
        switch type {
        case .wall:
            return "Mur vertical"
        case .slab:
            return "Dalle"
        case .overhang:
            return "Dévers"
        case .roof:
            return "Toit"
        case .traverse:
            return "Traversée"
        case .unknown:
            return "Autre"
        }
    }
    
    var imageName: String {
        switch type {
        case .wall:
            return "steepness.wall"
        case .slab:
            return "steepness.slab"
        case .overhang:
            return "steepness.overhang"
        case .roof:
            return "steepness.roof"
        case .traverse:
            return "steepness.traverse.left.right"
        case .unknown:
            return "steepness.unknown"
        }
    }
}
