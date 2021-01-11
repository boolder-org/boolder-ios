//
//  Steepness.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 03/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import Foundation

enum Steepness: String, CaseIterable  {    
    case wall
    case slab
    case overhang
    case roof
    case traverse
    case other
    
    var localizedName: String {
        switch self {
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
        switch self {
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
