//
//  TestFontSize.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 11/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TestFontSize: View {
    let sizes: [Font] = [
        .largeTitle,
        .title, .title2, .title3,
//        .headline, .subheadline,
        .body, .caption, .caption2,
//        .callout, .footnote
    ]

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(sizes, id: \.self) { font in
                Text("Hello, my name is Jean-Michel")
                    .font(font)
            }
            .font(.title)
        }
        .padding()
    }
}


struct TestFontSize_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TestFontSize().preferredColorScheme(.light)
            TestFontSize().preferredColorScheme(.dark)
        }
    }
}

