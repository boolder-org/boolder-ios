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
    
    // drag gesture (to dismiss the sheet)
    @State var dragOffset: CGSize = .zero
    @State var dragOffsetPredicted: CGSize = .zero
    
    var body: some View {
        @Bindable var mapState = mapState
        
        VStack {
            ZStack {
                VStack {
                    ZStack {
                        HStack {
                            if #available(iOS 26, *) {
                                Button(action: { dismiss() }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: UIFontMetrics.default.scaledValue(for: 24)))
                                        .padding(4)
                                }
                                .buttonStyle(.glass)
                                .buttonBorderShape(.circle)
                            }
                            else {
                                Button(action: { dismiss() }) {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(Color(UIColor.white))
                                        .font(.system(size: UIFontMetrics.default.scaledValue(for: 24)))
                                }
                            }
                            
                            Spacer()
                            
                            if #available(iOS 26, *) {
                                Button(action: { mapState.showAllLines.toggle() }) {
                                    Text("Vue bloc")
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                }
                                .modify {
                                    if mapState.showAllLines {
                                        $0.buttonStyle(.glassProminent)
                                    } else {
                                        $0.buttonStyle(.glass)
                                    }
                                }
                                .buttonBorderShape(.capsule)
                            }
                            else {
                                Button(action: { mapState.showAllLines.toggle() }) {
                                    Text("Vue bloc")
                                        .foregroundColor(Color(UIColor.white))
                                        .font(.body)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(mapState.showAllLines ? Color.accentColor.opacity(0.5) : Color.black.opacity(0.3))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    if !mapState.showAllLines {                        
                        overlayInfos
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        topoNavigationButtons
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: mapState.showAllLines)
                .edgesIgnoringSafeArea(.bottom)
                .zIndex(2)
                
                ZoomableScrollView(zoomScale: $zoomScale) {
                    TopoView(problem: $problem, zoomScale: $zoomScale, showAllLines: $mapState.showAllLines, onBackgroundTap: {
                        if !mapState.showAllLines && problem.otherProblemsOnSameTopo.count > 1 {
                            mapState.showAllLines = true
                        }
                    }, skipInitialBounceAnimation: true)
                }
                .containerRelativeFrame(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .zIndex(1)
                .offset(x: 0, y: self.dragOffset.height) // drag gesture
                .background(Color.systemBackground)
                .edgesIgnoringSafeArea(.all)
                
            }
            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var topoNavigationButtons: some View {
        HStack {
            if let previousTopo = previousTopo {
                Button(action: {
                    goToTopo(previousTopo)
                }) {
                    Label("Previous", systemImage: "chevron.left")
                }
                .modify {
                    if #available(iOS 26, *) {
                        $0.buttonStyle(.glass)
                            .buttonBorderShape(.capsule)
                    } else {
                        $0
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Capsule())
                    }
                }
            }
            
            Spacer()
            
            if let nextTopo = nextTopo {
                Button(action: {
                    goToTopo(nextTopo)
                }) {
                    Label("Next", systemImage: "chevron.right")
                        .environment(\.layoutDirection, .rightToLeft)
                }
                .modify {
                    if #available(iOS 26, *) {
                        $0.buttonStyle(.glass)
                            .buttonBorderShape(.capsule)
                    } else {
                        $0
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    private var nextTopo: Topo? {
        guard let topo = problem.topo, let boulderId = topo.boulderId else { return nil }
        return Boulder(id: boulderId).nextTopo(after: topo)
    }
    
    private var previousTopo: Topo? {
        guard let topo = problem.topo, let boulderId = topo.boulderId else { return nil }
        return Boulder(id: boulderId).previousTopo(before: topo)
    }
    
    private func goToTopo(_ topo: Topo) {
        if let topProblem = topo.topProblem {
            mapState.selectProblem(topProblem)
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
