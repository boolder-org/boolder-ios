//
//  FabButton.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 04/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct FabButton: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        return configuration.label
            .accentColor(.primary)
            .opacity(configuration.isPressed ? 0.2 : 1)
//            .frame(width: 18, height: 18)
            .padding(12)
//            .background(Color.systemBackground)
//            .clipShape(Circle())
//            .overlay(
//                Circle().stroke(Color(.secondaryLabel), lineWidth: 0.25)
//            )
//            .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
            .glassEffect(.regular)
    }
}
