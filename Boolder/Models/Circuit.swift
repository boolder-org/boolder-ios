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
                return #colorLiteral(red: 0.8763859868, green: 0.8711766005, blue: 0.8803905845, alpha: 1)
            }
        }
    }
    
    enum CircuitLevel {
        case beginner
        case unknown
    }
    
    init(color: CircuitColor, level: CircuitLevel, overlay: CircuitOverlay) {
        self.color = color
        self.level = level
        self.overlay = overlay
    }
    
    let color: CircuitColor
    let overlay: CircuitOverlay
    let level: CircuitLevel
    
    static func circuitColorFromString(_ string: String?) -> CircuitColor {
        switch string {
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
    
    static func circuitLevelFromString(_ string: String?) -> CircuitLevel {
        switch string {
        case "beginner":
            return CircuitLevel.beginner
        default:
            return CircuitLevel.unknown
        }
    }
    
    func localizedName() -> String {
        switch color {
        case .yellow:
            return NSLocalizedString("circuit.color.yellow", comment: "")
        case .orange:
            return NSLocalizedString("circuit.color.orange", comment: "")
        case .blue:
            return NSLocalizedString("circuit.color.blue", comment: "")
        case .skyBlue:
            return NSLocalizedString("circuit.color.skyblue", comment: "")
        case .red:
            return NSLocalizedString("circuit.color.red", comment: "")
        case .white:
            return NSLocalizedString("circuit.color.white", comment: "")
        case .whiteForKids:
            return NSLocalizedString("circuit.color.white_for_kids", comment: "")
        case .black:
            return NSLocalizedString("circuit.color.black", comment: "")
        default:
            return NSLocalizedString("circuit.color.no_name", comment: "")
        }
    }
}
