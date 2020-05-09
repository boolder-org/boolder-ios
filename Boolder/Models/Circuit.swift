//
//  Circuit.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 31/03/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import UIKit

class Circuit {
    enum CircuitColor: Int, Comparable {
        case whiteForKids
        case yellow
        case orange
        case blue
        case skyBlue
        case red
        case black
        case white
        case offCircuit
        
        static
        func < (lhs:Self, rhs:Self) -> Bool
        {
            return lhs.rawValue < rhs.rawValue
        }
        
        var uicolor: UIColor {
            switch self {
            case .whiteForKids:
                return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            case .yellow:
                return #colorLiteral(red: 1, green: 0.8, blue: 0.007843137255, alpha: 1)
            case .orange:
                return #colorLiteral(red: 1, green: 0.5843137255, blue: 0, alpha: 1)
            case .blue:
                return #colorLiteral(red: 0.003921568627, green: 0.4784313725, blue: 1, alpha: 1)
            case .skyBlue:
                return #colorLiteral(red: 0.3529411765, green: 0.7803921569, blue: 0.9803921569, alpha: 1)
            case .red:
                return #colorLiteral(red: 1, green: 0.231372549, blue: 0.1843137255, alpha: 1)
            case .black:
                return #colorLiteral(red: 0.1019607843, green: 0.1019607843, blue: 0.1019607843, alpha: 1)
            case .white:
                return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            case .offCircuit:
                return #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            }
        }
    }
    
    init(type: CircuitColor, name: String, overlay: CircuitOverlay? = nil) {
        self.type = type
        self.name = name
        self.overlay = overlay
    }
    
    let type: CircuitColor
    let name: String
    let overlay: CircuitOverlay? // FIXME: make non optional
    
    static func circuitTypeFromString(_ string: String?) -> CircuitColor {
        switch string {
        // FIXME Add white for kids
        case "yellow":
            return CircuitColor.yellow
        case "orange":
            return CircuitColor.orange
        case "blue":
            return CircuitColor.blue
        case "skyblue":
            return CircuitColor.skyBlue
        case "red":
            return CircuitColor.red
        case "black":
            return CircuitColor.black
        case "white":
            return CircuitColor.white
        default:
            return CircuitColor.offCircuit
        }
    }
}
