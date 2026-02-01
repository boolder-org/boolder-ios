//
//  GradeLabelView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 16/01/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct GradeLabelView: View {
    let grade: String
    let color: UIColor
    
    var body: some View {
        Text(grade)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(Color(readableColor))
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(Color(color))
            .clipShape(Capsule())
            .modifier(DropShadow())
    }
    
    var readableColor: UIColor {
        if color == Circuit.CircuitColor.white.uicolorForPhotoOverlay {
            return .black
        } else {
            return .white
        }
    }
}

