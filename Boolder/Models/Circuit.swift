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
        case purple
        case orange
        case green
        case blue
        case skyBlue
        case salmon
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
            case .purple:
                return #colorLiteral(red: 0.8431372549, green: 0.5137254902, blue: 1, alpha: 1)
            case .orange:
                return #colorLiteral(red: 1, green: 0.5843137255, blue: 0, alpha: 1)
            case .green:
                return #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            case .blue:
                return #colorLiteral(red: 0.003921568627, green: 0.4784313725, blue: 1, alpha: 1)
            case .skyBlue:
                return #colorLiteral(red: 0.3529411765, green: 0.7803921569, blue: 0.9803921569, alpha: 1)
            case .salmon:
                return #colorLiteral(red: 0.9921568627, green: 0.6862745098, blue: 0.5411764706, alpha: 1)
            case .red:
                return #colorLiteral(red: 1, green: 0.231372549, blue: 0.1843137255, alpha: 1)
            case .black:
                return #colorLiteral(red: 0.1019607843, green: 0.1019607843, blue: 0.1019607843, alpha: 1)
            case .white:
                return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            case .offCircuit:
                return #colorLiteral(red: 0.5308170319, green: 0.5417798758, blue: 0.5535028577, alpha: 1)
            }
        }
        
        func uicolorForPhotoOverlay() -> UIColor {
            if self == .offCircuit {
                return #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            }
            else {
                return uicolor
            }
        }
        
        func shortName() -> String {
            switch self {
            case .yellow:
                return NSLocalizedString("circuit.short_name.yellow", comment: "")
            case .purple:
                return NSLocalizedString("circuit.short_name.purple", comment: "")
            case .orange:
                return NSLocalizedString("circuit.short_name.orange", comment: "")
            case .green:
                return NSLocalizedString("circuit.short_name.green", comment: "")
            case .blue:
                return NSLocalizedString("circuit.short_name.blue", comment: "")
            case .skyBlue:
                return NSLocalizedString("circuit.short_name.skyblue", comment: "")
            case .salmon:
                return NSLocalizedString("circuit.short_name.salmon", comment: "")
            case .red:
                return NSLocalizedString("circuit.short_name.red", comment: "")
            case .white:
                return NSLocalizedString("circuit.short_name.white", comment: "")
            case .whiteForKids:
                return NSLocalizedString("circuit.short_name.white_for_kids", comment: "")
            case .black:
                return NSLocalizedString("circuit.short_name.black", comment: "")
            case .offCircuit:
                return NSLocalizedString("circuit.short_name.off_circuit", comment: "")
            }
        }
        
        func longName() -> String {
            switch self {
            case .yellow:
                return NSLocalizedString("circuit.long_name.yellow", comment: "")
            case .purple:
                return NSLocalizedString("circuit.long_name.purple", comment: "")
            case .orange:
                return NSLocalizedString("circuit.long_name.orange", comment: "")
            case .green:
                return NSLocalizedString("circuit.long_name.green", comment: "")
            case .blue:
                return NSLocalizedString("circuit.long_name.blue", comment: "")
            case .skyBlue:
                return NSLocalizedString("circuit.long_name.skyblue", comment: "")
            case .salmon:
                return NSLocalizedString("circuit.long_name.salmon", comment: "")
            case .red:
                return NSLocalizedString("circuit.long_name.red", comment: "")
            case .white:
                return NSLocalizedString("circuit.long_name.white", comment: "")
            case .whiteForKids:
                return NSLocalizedString("circuit.long_name.white_for_kids", comment: "")
            case .black:
                return NSLocalizedString("circuit.long_name.black", comment: "")
            case .offCircuit:
                return NSLocalizedString("circuit.long_name.off_circuit", comment: "")
            }
        }
    }
    
    init(id: Int, color: CircuitColor) {
        self.id = id
        self.color = color
    }
    
    let id: Int
    let color: CircuitColor
    
    static func circuitColorFromString(_ string: String?) -> CircuitColor {
        switch string {
        case "yellow":
            return CircuitColor.yellow
        case "purple":
            return CircuitColor.purple
        case "orange":
            return CircuitColor.orange
        case "green":
            return CircuitColor.green
        case "blue":
            return CircuitColor.blue
        case "skyblue":
            return CircuitColor.skyBlue
        case "salmon":
            return CircuitColor.salmon
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
