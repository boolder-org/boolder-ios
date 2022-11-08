//
//  LargeButton.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 19/12/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct LargeButton: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        return configuration.label
            .frame(maxWidth: .infinity)
            .background(Color.systemBackground)
            .foregroundColor(Color(UIColor.systemGreen))
            .opacity(configuration.isPressed ? 0.7 : 1)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(UIColor.systemGreen), lineWidth: 2)
            )
    }
}
