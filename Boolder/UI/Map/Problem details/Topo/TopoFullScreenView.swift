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
                                    Image("lines")
                                        .font(.system(size: UIFontMetrics.default.scaledValue(for: 24)))
                                        .padding(4)
                                }
                                .modify {
                                    if mapState.showAllLines {
                                        $0.buttonStyle(.glassProminent)
                                    } else {
                                        $0.buttonStyle(.glass)
                                    }
                                }
                                .buttonBorderShape(.circle)
                            }
                            else {
                                Button(action: { mapState.showAllLines.toggle() }) {
                                    Image("lines")
                                        .foregroundColor(Color(UIColor.white))
                                        .font(.system(size: UIFontMetrics.default.scaledValue(for: 24)))
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
                        topoCarousel
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
    
    var topoCarousel: some View {
        HStack(spacing: 8) {
            Button {
                goToPreviousTopo()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .frame(width: 54, height: 54)
                    .background(Color(.systemGray5))
                    .cornerRadius(6)
            }
            
            GeometryReader { geo in
                let count = CGFloat(boulderTopos.count)
                let totalSpacing = 8 * max(count - 1, 0)
                let thumbnailWidth = min(72, max(0, (geo.size.width - totalSpacing) / max(count, 1)))
                
                HStack(spacing: 8) {
                    ForEach(Array(boulderTopos.enumerated()), id: \.element.id) { index, topo in
                        topoThumbnail(topo: topo, isCurrent: topo.id == problem.topoId, width: thumbnailWidth, index: index)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 54)
            
            Button {
                goToNextTopo()
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
                    .frame(width: 54, height: 54)
                    .background(Color(.systemGray5))
                    .cornerRadius(6)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom)
        .safeAreaPadding(.bottom)
    }
    
    @ViewBuilder
    private func topoThumbnail(topo: Topo, isCurrent: Bool, width: CGFloat, index: Int) -> some View {
        let letter = String(UnicodeScalar("A".unicodeScalars.first!.value + UInt32(index))!)
        
        return Button {
            goToTopo(topo)
        } label: {
            if let photo = topo.onDiskPhoto {
                Image(uiImage: photo)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: 54)
                    .clipped()
                    .cornerRadius(6)
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.secondarySystemFill))
                    .frame(width: width, height: 54)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isCurrent ? Color.accentColor : Color.clear, lineWidth: 2.5)
        )
        .overlay {
            Text(letter)
                .font(.caption2.weight(.semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(white: 0.3).opacity(0.9), in: RoundedRectangle(cornerRadius: 2))
        }
    }
    
    private var boulderTopos: [Topo] {
        guard let topo = problem.topo, let boulderId = topo.boulderId else { return [] }
        return Boulder(id: boulderId).topos
    }
    
    private func goToTopo(_ topo: Topo) {
        if let topProblem = topo.topProblem {
            mapState.selectProblem(topProblem)
        }
    }
    
    private func goToPreviousTopo() {
        guard let topo = problem.topo, let boulderId = topo.boulderId,
              let previous = Boulder(id: boulderId).previousTopo(before: topo) else { return }
        goToTopo(previous)
    }
    
    private func goToNextTopo() {
        guard let topo = problem.topo, let boulderId = topo.boulderId,
              let next = Boulder(id: boulderId).nextTopo(after: topo) else { return }
        goToTopo(next)
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
