//
//  ToposView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 11/09/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ToposView: View {
    @State private var currentPage = 0
    @Binding var problem: Problem
    @ObservedObject var mapState: MapState
    
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<10) { index in
                ZStack {
                    TopoView(
                        problem: $problem,
                        mapState: mapState
                    )
                        .tag(index) // Assign a tag to each item for selection tracking
                }
            }
        }
//            .frame(height: 250)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .onChange(of: currentPage) { newPage in
            print("Page turned to: \(newPage)")
            // Add any action you want to perform when the page changes
        }
    }
}

//#Preview {
//    ToposView()
//}
