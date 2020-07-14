//
//  Steepness.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 03/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import Foundation

class Steepness  {
    enum SteepnessType: CaseIterable {
        case wall
        case slab
        case overhang
        case roof
        case traverse
        case other
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
        case "other":
            self.type = .other
        default:
            // FIXME: add warning
            self.type = .other
        }
    }
    
    var name: String {
        switch type {
        case .wall:
            return NSLocalizedString("steepness.wall", comment: "")
        case .slab:
            return NSLocalizedString("steepness.slab", comment: "")
        case .overhang:
            return NSLocalizedString("steepness.overhang", comment: "")
        case .roof:
            return NSLocalizedString("steepness.roof", comment: "")
        case .traverse:
            return NSLocalizedString("steepness.traverse", comment: "")
        case .other:
            return NSLocalizedString("steepness.other", comment: "")
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
        case .other:
            return "steepness.other"
        }
    }
}
