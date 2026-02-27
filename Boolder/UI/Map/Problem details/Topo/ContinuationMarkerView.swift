//
//  ContinuationMarkerView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 26/02/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ContinuationMarkerView: View {
    let color: UIColor
    let direction: Direction
    let onTap: () -> Void
    
    enum Direction {
        case forward
        case backward
        
        var chevronName: String {
            switch self {
            case .forward: return "chevron.right"
            case .backward: return "chevron.left"
            }
        }
    }
    
    private let height: CGFloat = 24
    private let width: CGFloat = 28
    
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color(color))
            .modifier(DropShadow())
            .overlay(
                Image(systemName: direction.chevronName)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(readableColor()))
            )
            .frame(width: width, height: height)
            .onTapGesture {
                onTap()
            }
    }
    
    private func readableColor() -> UIColor {
        if color == Circuit.CircuitColor.white.uicolor || color == Circuit.CircuitColor.white.uicolorForPhotoOverlay {
            return .black
        }
        return .white
    }
}
