//
//  ProblemNameLabelView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 12/02/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ProblemNameLabelView: View {
    let name: String
    let color: UIColor
    
    var body: some View {
        Text(name)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(Color(readableColor))
            .lineLimit(1)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color(color), in: RoundedRectangle(cornerRadius: 4))
    }
    
    var readableColor: UIColor {
        if color == Circuit.CircuitColor.white.uicolorForPhotoOverlay {
            return .black
        } else {
            return .white
        }
    }
}

