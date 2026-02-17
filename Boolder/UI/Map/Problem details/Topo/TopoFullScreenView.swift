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
    @State private var scrolledTopoId: Int?
    
    @State private var presentBoulderProblemsList = false
    
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
                                    if mapState.isInTopoMode {
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
                    
                    if mapState.isInTopoMode {
                        topoCarousel
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
        .onAppear {
            scrolledTopoId = problem.topoId
        }
        .onChange(of: problem.topoId) { _, newTopoId in
            if let newTopoId, scrolledTopoId != newTopoId {
                withAnimation {
                    scrolledTopoId = newTopoId
                }
            }
        }
        .sheet(isPresented: $presentBoulderProblemsList) {
            let scrolledBoulderId = mapState.boulderTopos.first(where: { $0.id == scrolledTopoId })?.boulderId
            BoulderProblemsListView(problems: mapState.boulderProblems, boulderId: scrolledBoulderId, currentTopoId: scrolledTopoId)
                .presentationDetents([.large])
        }
    }
    
    // MARK: - Topo horizontal swipe
    
    @ViewBuilder
    private var fullScreenTopoContent: some View {
        if mapState.boulderTopos.count > 1 {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(mapState.boulderTopos) { topo in
                        FullScreenTopoPageView(
                            topo: topo,
                            topProblem: mapState.topProblem(for: topo.id) ?? Problem.empty
                        )
                        .containerRelativeFrame(.horizontal)
                        .frame(maxHeight: .infinity)
                        .id(topo.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrolledTopoId)
            .scrollIndicators(.hidden)
            .onChange(of: scrolledTopoId) { _, newId in
                guard let newId,
                      let topo = mapState.boulderTopos.first(where: { $0.id == newId }),
                      problem.topoId != newId else { return }
                // Only update selection when leaving problem mode.
                // In topo mode, selection stays put → zero view invalidation during swipe.
                if case .problem = mapState.selection {
                    Task { @MainActor in
                        mapState.selection = .topo(topo: topo)
                    }
                }
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
    
    private var boulderProblems: [Problem] {
        mapState.boulderProblems
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
                    let count = CGFloat(mapState.boulderTopos.count)
                    let totalSpacing = 8 * max(count - 1, 0)
                    let thumbnailWidth = min(72, max(0, (geo.size.width - totalSpacing) / max(count, 1)))
                    
                    HStack(spacing: 8) {
                        ForEach(Array(mapState.boulderTopos.enumerated()), id: \.element.id) { index, topo in
                            topoThumbnail(topo: topo, isCurrent: topo.id == scrolledTopoId, width: thumbnailWidth, index: index)
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
                    let count = mapState.allProblemsCount(for: scrolledTopoId ?? 0)
                    Text(String(format: NSLocalizedString(count == 1 ? "boulder.info_basic_singular" : "boulder.info_basic", comment: ""), count))
                    Image(systemName: "chevron.right")
                }
                .font(.callout)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
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
    
    private func toggleTopoSelection() {
        if case .problem(let problem, _) = mapState.selection, let topo = problem.topo {
            mapState.selection = .topo(topo: topo)
        } else if let currentId = scrolledTopoId,
                  let topo = mapState.boulderTopos.first(where: { $0.id == currentId }),
                  let topProblem = mapState.topProblem(for: topo.id) {
            mapState.selectProblem(topProblem)
        }
    }
    
    private func goToTopo(_ topo: Topo) {
        withAnimation {
            scrolledTopoId = topo.id
        }
        mapState.selection = .topo(topo: topo)
    }
    
    private func goToPreviousTopo() {
        guard let currentId = scrolledTopoId,
              let current = mapState.boulderTopos.first(where: { $0.id == currentId }),
              let previous = mapState.previousTopo(before: current) else { return }
        goToTopo(previous)
    }
    
    private func goToNextTopo() {
        guard let currentId = scrolledTopoId,
              let current = mapState.boulderTopos.first(where: { $0.id == currentId }),
              let next = mapState.nextTopo(after: current) else { return }
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

// MARK: - Full-screen topo page wrapper (per-page state + zoom for LazyHStack)

private struct FullScreenTopoPageView: View {
    let topo: Topo
    @State private var problem: Problem
    @State private var zoomScale: CGFloat = 1
    @Environment(MapState.self) private var mapState
    
    init(topo: Topo, topProblem: Problem) {
        self.topo = topo
        self._problem = State(initialValue: topProblem)
    }
    
    var body: some View {
        ZoomableScrollView(zoomScale: $zoomScale) {
            TopoView(problem: $problem, zoomScale: $zoomScale, onBackgroundTap: {
                if case .problem = mapState.selection, problem.otherProblemsOnSameTopo.count > 1, let topo = problem.topo {
                    mapState.selection = .topo(topo: topo)
                }
            }, skipInitialBounceAnimation: true)
        }
        .onChange(of: mapState.isInTopoMode, initial: true) { _, isTopoMode in
            if isTopoMode {
                // Topo mode: show the cached top problem
                if let cached = mapState.topProblem(for: topo.id), cached.id != problem.id {
                    problem = cached
                }
            } else {
                // Problem mode: show the selected problem if it belongs to this topo
                if case .problem(let p, _) = mapState.selection, p.topoId == topo.id, p.id != problem.id {
                    problem = p
                }
            }
        }
    }
}

//struct TopoFullScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        TopoFullScreenView()
//    }
//}
