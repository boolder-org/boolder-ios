//
//  BoulderFullScreenView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 15/05/2025.
//  Copyright © 2025 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct BoulderFullScreenView: View {
    @State private var zoomScale: CGFloat = 1
//    @Binding var problem: Problem
    @ObservedObject var mapState: MapState
    
    var body: some View {
        GeometryReader { proxy in
            
            ZoomableScrollView(zoomScale: $zoomScale) {
                TopoView(
                    topo: mapState.selectedProblem.topo!,
                    problem: $mapState.selectedProblem,
                    mapState: mapState
                )
                    .frame(width: proxy.size.width, height: proxy.size.height)
            }
            .background(Color.black)
            .ignoresSafeArea()
            .onChange(of: zoomScale) { newValue in
                print(newValue)
            }
        }
    }
}

//#Preview {
//    BoulderFullScreenView()
//}
