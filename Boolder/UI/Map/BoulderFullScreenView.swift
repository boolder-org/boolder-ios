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
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    var body: some View {
        Color.systemBackground
            .opacity(Double(1 - min(abs(dragOffset) / 500, 1)))
            .ignoresSafeArea()
            .overlay(
                ZStack {
                    
                    
                    ZoomableScrollView(zoomScale: $zoomScale) {
                        TopoView(
                            //                    topo: mapState.selectedProblem.topo!,
                            problem: $mapState.selectedProblem,
                            mapState: mapState,
                            zoomScale: $zoomScale,
                            onBackgroundTap: {
                                // do something?
                            }
                        )
                    }
                    
                    .matchedGeometryEffect(id: "photo", in: animation, isSource: true)
                    .frame(maxWidth: .infinity)
                    
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // greedy to take the full screen
                    .ignoresSafeArea()
                    .offset(y: dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                isDragging = true
                                dragOffset = gesture.translation.height
                            }
                            .onEnded { gesture in
                                isDragging = false
                                
                                if abs(gesture.translation.height) >= 44 {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        presentFullScreen = false
                                    }
                                }
                            }
                    )
                    
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
            )
    }
}

//#Preview {
//    BoulderFullScreenView()
//}
