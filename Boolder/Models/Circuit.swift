//
//  Circuit.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 31/03/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import UIKit

class Circuit {
    enum CircuitType: Int, Comparable {
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
    }
    
    let type: CircuitType
    
    init(_ type: CircuitType) {
        self.type = type
    }
    
    var name: String {
        switch type {
        case .whiteForKids:
            return "Blanc (enfants)"
        case .yellow:
            return "Jaune"
        case .orange:
            return "Orange"
        case .blue:
            return "Bleu"
        case .skyBlue:
            return "Bleu ciel"
        case .red:
            return "Rouge"
        case .black:
            return "Noir"
        case .white:
            return "Blanc"
        case .offCircuit:
            return "Hors circuit"
        }
    }
    
    var overallLevelDescription: String {
        switch type {
        case .whiteForKids:
            return "1"
        case .yellow:
            return "1b à 3b"
        case .orange:
            return "1a à 4c"
        case .blue:
            return "3b à 5c"
        case .skyBlue:
            return "3b à 6a"
        case .red:
            return "4c à 6b"
        case .black:
            return "6"
        case .white:
            return "6b à 7c"
        case .offCircuit:
            return ""
        }
    }
    
    var color: UIColor {
        switch type {
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
    
    static func circuitTypeFromString(_ string: String?) -> CircuitType {
        switch string {
        // FIXME Add white for kids
        case "yellow":
            return CircuitType.yellow
        case "orange":
            return CircuitType.orange
        case "blue":
            return CircuitType.blue
        case "skyblue":
            return CircuitType.skyBlue
        case "red":
            return CircuitType.red
        case "black":
            return CircuitType.black
        case "white":
            return CircuitType.white
        default:
            return CircuitType.offCircuit
        }
    }
}
