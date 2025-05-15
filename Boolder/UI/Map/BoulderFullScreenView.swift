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
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topTrailing) {
                ZoomableScrollView(zoomScale: $zoomScale) {
                    TopoView(
                        topo: mapState.selectedProblem.topo!,
                        problem: $mapState.selectedProblem,
                        mapState: mapState,
                        zoomScale: $zoomScale
                    )
                        .frame(width: proxy.size.width, height: proxy.size.height)
                }
                .background(Color.black)
                .ignoresSafeArea()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .padding(16)
                }
            }
        }
    }
}

//#Preview {
//    BoulderFullScreenView()
//}
