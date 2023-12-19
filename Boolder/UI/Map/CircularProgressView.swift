//
//  CircularProgressView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 15/12/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.appGreen.opacity(0.3),
                    lineWidth: 3
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.appGreen,
                    style: StrokeStyle(
                        lineWidth: 3,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                // 1
                .animation(.easeOut, value: progress)

        }
    }
}

#Preview {
    List {
        HStack {
            Text("coucou")
            Spacer()
            Image(systemName: "arrow.down.circle.fill").resizable().aspectRatio(contentMode: .fit).frame(height: 24).foregroundColor(.appGreen)
            CircularProgressView(progress: 0.5).frame(height: 20)
        }
    }
}
