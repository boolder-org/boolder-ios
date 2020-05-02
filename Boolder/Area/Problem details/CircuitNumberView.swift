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
    
    func readableColor() -> UIColor {
        if color == Circuit(.white).color {
            return .label
        }
        else {
            return .systemBackground
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(color))
                .frame(width: 28, height: 28)
            Text(number)
                .font(.headline)
                .foregroundColor(Color(readableColor()))
        }
    }
}

struct CircuitNumberView_Previews: PreviewProvider {
    static var previews: some View {
        CircuitNumberView(number: "17", color: .red)
    }
}
