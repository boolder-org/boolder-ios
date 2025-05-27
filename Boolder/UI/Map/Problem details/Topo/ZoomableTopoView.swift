//
//  ZoomableTopoView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/05/2025.
//  Copyright © 2025 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ZoomableTopoView: View {
    let topo: Topo
    @State private var zoomScale: CGFloat = 1
    @ObservedObject var mapState: MapState
    var animation: Namespace.ID
    
    var body: some View {
        ZoomableScrollView(zoomScale: $zoomScale) {
            TopoView(
                topo: topo,
//                            problem: $mapState.selectedProblem,
                mapState: mapState,
                zoomScale: $zoomScale,
                onBackgroundTap: {
                    mapState.showAllStarts = true
                }
            )
        }
        
        .matchedGeometryEffect(id: "topo-\(topo.id)", in: animation, isSource: true)
//        .frame(maxWidth: .infinity)
        .containerRelativeFrame(.horizontal)
        
        .frame(maxWidth: .infinity, maxHeight: .infinity) // greedy to take the full screen
        .ignoresSafeArea()
//        .offset(y: dragOffset)
//        .gesture(
//            // TODO: use PanGesture like https://www.youtube.com/watch?v=vqPK8qFsoBg
//            DragGesture()
//                .onChanged { gesture in
//                    isDragging = true
//                    dragOffset = gesture.translation.height
//                }
//                .onEnded { gesture in
//                    isDragging = false
//
//
//                    if abs(gesture.translation.height) >= 80 {
//                        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
//                            presentFullScreen = false
//                        }
//                    }
//                    else {
//                        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
//                            dragOffset = 0
//                        }
//                    }
//                }
//        )
    }
}

//#Preview {
//    ZoomableTopoView()
//}
