//
//  ContentView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 13/01/2021.
//  Copyright © 2021 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TestColorView: View {
    let standardColors: [Color] = [
        .black, .white, .gray, .red, .green, .blue, .orange,
        .yellow, .pink, .purple, .primary, .secondary, .accentColor
    ]

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(standardColors, id: \.self) { color in
                Text(color.description)
                    .bold()
                    .foregroundColor(color)
            }
            .font(.title)
        }
        .padding()
    }
}

struct TestUIColorView: View {
    let uiColors: [UIColor] = [
        .secondaryLabel,
        .secondarySystemFill,
        .secondarySystemBackground,
        .secondarySystemGroupedBackground,
        .systemBackground,
        .systemGroupedBackground
    ]

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(uiColors, id: \.self) { color in
                Text(color.accessibilityName)
                    .bold()
                    .foregroundColor(Color(color))
            }
            .font(.title)
        }
        .padding()
    }
}

struct TestColorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TestColorView().preferredColorScheme(.light)
            TestColorView().preferredColorScheme(.dark)
            TestUIColorView().preferredColorScheme(.light)
            TestUIColorView().preferredColorScheme(.dark)
        }
    }
}
