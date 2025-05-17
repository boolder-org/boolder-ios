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
//    @Environment(\.dismiss) private var dismiss
    
    @Binding var presentFullScreen: Bool
    var animation: Namespace.ID
    
    var body: some View {
            ZStack(alignment: .topTrailing) {
                Color.white
                    .ignoresSafeArea()
                
//                ZoomableScrollView(zoomScale: $zoomScale) {
//                    TopoView(
//                        topo: mapState.selectedProblem.topo!,
//                        problem: $mapState.selectedProblem,
//                        mapState: mapState,
//                        zoomScale: $zoomScale
//                    )
                Image("yellow-circuit-start")
                    .resizable()
                    .scaledToFit()
                    .matchedGeometryEffect(id: "photo", in: animation, isSource: true)
//                    .matchedTransitionSource(id: "photo", in: animation)
                    
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                }
//                .background(Color.white)
//                .ignoresSafeArea()
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        presentFullScreen = false
                    }
                   
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.primary)
                        .padding(16)
                }
            }
//        .navigationTransition(.zoom(sourceID: "photo", in: animation))
    }
}

//#Preview {
//    BoulderFullScreenView()
//}
