//
//  CircuitNumberView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 02/05/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct CircuitNumberView: View {
    var number: String
    var color: UIColor
    var showStroke = true
    var height: CGFloat = 28
    
    func readableColor() -> UIColor {
        if color == Circuit.CircuitColor.white.uicolor {
            return .black
        }
        else {
            return .systemBackground
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(color))
            Text(number)
                .font(.headline)
                .foregroundColor(Color(readableColor()))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .overlay(
                    Circle()
                        .stroke(Color(UIColor.systemGray3), lineWidth: 1)
                        .frame(width: height, height: height)
                        .opacity(color == Circuit.CircuitColor.white.uicolor && showStroke ? 1.0 : 0.0)
                )
                .frame(width: height-2, height: height-2)
        }
        .frame(width: height, height: height)
    }
}

struct CircuitNumberView_Previews: PreviewProvider {
    static var previews: some View {
        CircuitNumberView(number: "17", color: .red)
            .previewLayout(.fixed(width: 50, height: 50))
    }
}
