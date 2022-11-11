//
//  CircuitNumberView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 02/05/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct CircleView: View {
    static var defaultHeight: CGFloat = 28
    
    var number: String
    var color: UIColor
    var showStroke = true
    var showShadow = false
    var height: CGFloat = Self.defaultHeight
    var scaleEffect: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(color))
                .modifier(DropShadow(visible: showShadow))
            Text(number)
                .font(.headline)
                .fontWeight(.regular)
                .foregroundColor(Color(readableColor()))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .overlay(
                    Circle()
                        .stroke(Color(UIColor.systemGray3), lineWidth: 1)
                        .frame(width: height, height: height)
                        .opacity(showStroke ? 1.0 : 0.0)
                )
                .frame(width: height-2, height: height-2)
        }
        .scaleEffect(scaleEffect)
        .frame(width: height, height: height)
    }
    
    func readableColor() -> UIColor {
        if color == Circuit.CircuitColor.white.uicolor {
            return .black
        }
        else {
            return .systemBackground
        }
    }
}

struct CircuitNumberView_Previews: PreviewProvider {
    static var previews: some View {
        CircleView(number: "45", color: .red)
            .previewLayout(.fixed(width: 50, height: 50))
    }
}
