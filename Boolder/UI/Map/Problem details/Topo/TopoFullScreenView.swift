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
    
    @Binding var problem: Problem
    
    @State private var zoomScale: CGFloat = 1
    
    var body: some View {
        @Bindable var mapState = mapState
        
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
                                        .foregroundColor(Color(UIColor.white))
                                        .font(.system(size: UIFontMetrics.default.scaledValue(for: 24)))
                                }
                            }
                            

                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    if mapState.isInTopoMode {
                        TopoCarouselView(problem: $problem, style: .overlay)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        overlayInfos
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: mapState.isInTopoMode)
                .edgesIgnoringSafeArea(.bottom)
                .zIndex(2)
                
                fullScreenTopoContent
                    .zIndex(1)
                    .background(Color.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
            }
            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Topo horizontal swipe
    
    @ViewBuilder
    private var fullScreenTopoContent: some View {
        if mapState.boulderTopos.count > 1 {
            TopoLoopScrollView(
                boulderTopos: mapState.boulderTopos,
                topoId: problem.topoId,
                boulderId: mapState.cachedBoulderId,
                onTopoChanged: { topo in
                    guard problem.topoId != topo.id else { return }
                    mapState.selection = .topo(topo: topo)
                }
            ) { topo in
                TopoPageView(
                    topo: topo,
                    topProblem: mapState.topProblem(for: topo.id) ?? Problem.empty,
                    zoomable: true,
                    backgroundTapTogglesMode: true
                )
                .frame(maxHeight: .infinity)
            }
        } else {
            ZoomableScrollView(zoomScale: $zoomScale) {
                TopoView(problem: $problem, zoomScale: $zoomScale, onBackgroundTap: {
                    if case .problem = mapState.selection, problem.otherProblemsOnSameTopo.count > 1, let topo = problem.topo {
                        mapState.selection = .topo(topo: topo)
                    }
                }, skipInitialBounceAnimation: true)
            }
            .containerRelativeFrame(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    var overlayInfos: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProblemInfoView(problem: problem)
                .foregroundColor(.primary.opacity(0.8))
            
            ProblemActionButtonsView(problem: $problem, withHorizontalPadding: false, onCircuitSelected: { dismiss() })
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
