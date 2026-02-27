//
//  TopoFullScreenView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 10/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TopoFullScreenView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MapState.self) private var mapState: MapState
    @State private var dismissOffset: CGFloat = 0
    @State private var isDismissDragging = false
    
    var body: some View {
        if let problem = mapState.selectedProblem {
            VStack {
                ZStack {
                    VStack {
                        ZStack {
                            HStack {
                                Spacer()
                                
                                if #available(iOS 26, *) {
                                    Button(action: { dismiss() }) {
                                        Image(systemName: "xmark")
                                            .font(.system(size: UIFontMetrics.default.scaledValue(for: 24)))
                                            .padding(4)
                                    }
                                    .buttonStyle(.glass)
                                    .buttonBorderShape(.circle)
                                }
                                else {
                                    Button(action: { dismiss() }) {
                                        Image(systemName: "xmark")
                                            .foregroundColor(.primary)
                                            .font(.system(size: UIFontMetrics.default.scaledValue(for: 16)))
                                            .frame(width: 32, height: 32)
                                            .background(.regularMaterial, in: Circle())
                                    }
                                }
                            }
                        }
                        .padding()
                        
                        Spacer()
                        
                        if mapState.isInTopoMode {
                            TopoCarouselView(problem: problem, style: .overlay)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        } else {
                            overlayInfos(problem: problem)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: mapState.isInTopoMode)
                    .edgesIgnoringSafeArea(.bottom)
                    .zIndex(2)
                    
                    TopoSwipeContentView(problem: problem, zoomable: true)
                        .zIndex(1)
                        .background(Color.systemBackground)
                        .edgesIgnoringSafeArea(.all)
                }
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .scaleEffect(dismissScale, anchor: .center)
            .offset(y: dismissOffset)
            .simultaneousGesture(dismissDragGesture)
        }
    }
    
    private var dismissScale: CGFloat {
        1 - min(max(dismissOffset, 0) / 1000, 0.1)
    }
    
    private var dismissDragGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                if !isDismissDragging {
                    guard value.translation.height > 0,
                          abs(value.translation.height) > abs(value.translation.width) else { return }
                    isDismissDragging = true
                }
                if isDismissDragging {
                    dismissOffset = max(0, value.translation.height)
                }
            }
            .onEnded { value in
                if isDismissDragging {
                    if dismissOffset > 120 || value.predictedEndTranslation.height > 500 {
                        dismissOffset = 0
                        dismiss()
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            dismissOffset = 0
                        }
                    }
                }
                isDismissDragging = false
            }
    }
    
    private func overlayInfos(problem: Problem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ProblemInfoView(problem: problem)
                .foregroundColor(.primary.opacity(0.8))
            
            ProblemActionButtonsView(problem: problem, withHorizontalPadding: false, onCircuitSelected: { dismiss() })
        }
        .padding()
        .frame(minHeight: 150, alignment: .top)
        .modify {
            if #available(iOS 26, *) {
                $0.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 0))
            }
            else {
                $0.background(Color.systemBackground)
            }
        }
    }
}

//struct TopoFullScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        TopoFullScreenView()
//    }
//}
