//
//  File.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 03/02/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct BoolderSecondaryButtonStyle: ButtonStyle {
    let fill: Bool
    
    func makeBody(configuration: Self.Configuration) -> some View {
        return configuration.label
//            .frame(maxWidth: .infinity)
            .background(fill ? Color(UIColor.systemGreen) : Color.systemBackground)
            .foregroundColor(fill ? Color(UIColor.systemBackground) : Color(UIColor.systemGreen))
            .opacity(configuration.isPressed ? 0.7 : 1)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(UIColor.systemGreen), lineWidth: 1)
            )
    }
}
