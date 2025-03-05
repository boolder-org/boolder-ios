//
//  GradeBadgeView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 04/03/2025.
//  Copyright © 2025 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct GradeBadgeView: View {
    static var defaultHeight: CGFloat = 22
    
    var number: String
    var color: UIColor
    var showStroke = true
    var showShadow = false
    var height: CGFloat = Self.defaultHeight
    var scaleEffect: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                .fill(Color(color))
//                .fill(.white)
                .modifier(DropShadow(visible: showShadow))
            Text(number)
//                .foregroundColor(Color(color))
                .font(.caption)
                .fontWeight(.regular)
                .foregroundColor(Color(readableColor()))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .overlay(
                    RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                        .stroke(Color(UIColor.systemGray3), lineWidth: 1)
                        .frame(width: height, height: height)
                        .opacity(showStroke ? 1.0 : 0.0)
                )
                .frame(width: height-2, height: height-2)
        }
        .scaleEffect(0.7)
        .frame(width: height, height: height)
    }
    
    func readableColor() -> UIColor {
        if color == Circuit.CircuitColor.white.uicolor {
            return .black
        }
        else {
            return .white
        }
    }
}

#Preview {
    GradeBadgeView(number: "4a", color: .red)
}
