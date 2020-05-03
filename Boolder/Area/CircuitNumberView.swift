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
    
    func readableColor() -> UIColor {
        if color == Circuit(.white).color {
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
                        .stroke(Color.black, lineWidth: 1)
                        .frame(width: 28, height: 28)
                        .opacity(color == Circuit(.white).color && showStroke ? 1.0 : 0.0)
                )
                .frame(width: 26, height: 26)
        }
        .frame(width: 28, height: 28)
    }
}

struct CircuitNumberView_Previews: PreviewProvider {
    static var previews: some View {
        CircuitNumberView(number: "17", color: .red)
            .previewLayout(.fixed(width: 50, height: 50))
    }
}
