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
    
    @State private var presentBoulderProblemsList = false
    
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
                                Button(action: { toggleTopoSelection() }) {
                                    Image(systemName: "binoculars.fill")
                                        .font(.system(size: UIFontMetrics.default.scaledValue(for: 24)))
                                        .padding(4)
                                }
                                .modify {
                                    if case .topo = mapState.selection {
                                        $0.buttonStyle(.glassProminent)
                                            .buttonBorderShape(.circle)
                                    } else {
                                        $0.buttonStyle(.glass)
                                            .buttonBorderShape(.circle)
                                    }
                                }
                            }
                            else {
                                Button(action: { toggleTopoSelection() }) {
                                    Image(systemName: "binoculars.fill")
                                        .foregroundColor(Color(UIColor.white))
                                        .font(.system(size: UIFontMetrics.default.scaledValue(for: 24)))
                                }
                            }

                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    if case .topo = mapState.selection {
                        topoCarousel
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        overlayInfos
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: mapState.selection)
                .edgesIgnoringSafeArea(.bottom)
                .zIndex(2)
                
                ZoomableScrollView(zoomScale: $zoomScale) {
                    TopoView(problem: $problem, zoomScale: $zoomScale, onBackgroundTap: {
                        if case .problem = mapState.selection, problem.otherProblemsOnSameTopo.count > 1, let topo = problem.topo {
                            mapState.selection = .topo(topo: topo)
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
        .sheet(isPresented: $presentBoulderProblemsList) {
            BoulderProblemsListView(problems: boulderProblems, boulderId: mapState.selectedTopo?.boulderId, currentTopoId: mapState.selectedTopo?.id)
                .presentationDetents([.large])
        }
    }
    
    private var boulderProblems: [Problem] {
        guard let topo = mapState.selectedTopo, let boulderId = topo.boulderId else { return [] }
        return Boulder(id: boulderId).problems
    }
    
    var topoCarousel: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Button {
                    goToPreviousTopo()
                } label: {
                    Image(systemName: "arrow.left")
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
                            topoThumbnail(topo: topo, isCurrent: topo.id == mapState.selectedTopo?.id, width: thumbnailWidth, index: index)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(height: 54)
                
                Button {
                    goToNextTopo()
                } label: {
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white)
                        .frame(width: 54, height: 54)
                        .background(Color(.systemGray5))
                        .cornerRadius(6)
                }
            }
            
            Button {
                presentBoulderProblemsList = true
            } label: {
                HStack(spacing: 4) {
                    Text(String(format: NSLocalizedString((mapState.selectedTopo?.allProblems.count ?? 0) == 1 ? "boulder.info_basic_singular" : "boulder.info_basic", comment: ""), mapState.selectedTopo?.allProblems.count ?? 0))
                    Image(systemName: "chevron.right")
                }
                .font(.callout)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(Color.gray, lineWidth: 1)
//                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(.regularMaterial)
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
        guard let topo = mapState.selectedTopo, let boulderId = topo.boulderId else { return [] }
        return Boulder(id: boulderId).topos
    }
    
    private func toggleTopoSelection() {
        if case .problem(let problem) = mapState.selection, let topo = problem.topo {
            mapState.selection = .topo(topo: topo)
        } else if case .topo(let topo) = mapState.selection, let topProblem = topo.topProblem {
            mapState.selectProblem(topProblem)
        }
    }
    
    private func goToTopo(_ topo: Topo) {
        mapState.selection = .topo(topo: topo)
    }
    
    private func goToPreviousTopo() {
        guard let currentTopo = mapState.selectedTopo, let boulderId = currentTopo.boulderId,
              let previous = Boulder(id: boulderId).previousTopo(before: currentTopo) else { return }
        goToTopo(previous)
    }
    
    private func goToNextTopo() {
        guard let currentTopo = mapState.selectedTopo, let boulderId = currentTopo.boulderId,
              let next = Boulder(id: boulderId).nextTopo(after: currentTopo) else { return }
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

