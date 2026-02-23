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
