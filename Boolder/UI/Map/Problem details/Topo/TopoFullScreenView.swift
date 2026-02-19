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
    @State private var lastSeenBoulderId: Int?
    @State private var thumbnailPhotos: [Int: UIImage] = [:]
    @State private var thumbnailTask: Task<Void, Never>?
    
    private func buildThumbnailPhotos() {
        let topos = mapState.boulderTopos
        thumbnailTask?.cancel()
        thumbnailTask = Task(priority: .utility) {
            var photos: [Int: UIImage] = [:]
            for topo in topos {
                if Task.isCancelled { return }
                if let image = await TopoImageCache.shared.image(for: topo) {
                    photos[topo.id] = image
                }
            }
            if Task.isCancelled { return }
            await MainActor.run {
                thumbnailPhotos = photos
            }
        }
    }
    
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
            buildThumbnailPhotos()
            lastSeenBoulderId = mapState.cachedBoulderId
        }
        .onChange(of: problem.topoId) { _, _ in
            if lastSeenBoulderId != mapState.cachedBoulderId {
                lastSeenBoulderId = mapState.cachedBoulderId
                buildThumbnailPhotos()
            }
        }
        .onDisappear {
            thumbnailTask?.cancel()
            thumbnailTask = nil
        }
        .sheet(isPresented: $presentBoulderProblemsList) {
            let currentBoulderId = mapState.boulderTopos.first(where: { $0.id == problem.topoId })?.boulderId
            BoulderProblemsListView(problems: mapState.boulderProblems, boulderId: currentBoulderId, currentTopoId: problem.topoId)
                .presentationDetents([.large])
        }
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
                FullScreenTopoPageView(
                    topo: topo,
                    topProblem: mapState.topProblem(for: topo.id) ?? Problem.empty
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
    
    private var boulderProblems: [Problem] {
        mapState.boulderProblems
    }
    
    var topoCarousel: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                GeometryReader { geo in
                    let count = CGFloat(mapState.boulderTopos.count)
                    let totalSpacing = 8 * max(count - 1, 0)
                    let thumbnailWidth = min(72, max(0, (geo.size.width - totalSpacing) / max(count, 1)))
                    
                    HStack(spacing: 8) {
                        ForEach(Array(mapState.boulderTopos.enumerated()), id: \.element.id) { index, topo in
                            topoThumbnail(topo: topo, isCurrent: topo.id == problem.topoId, width: thumbnailWidth, index: index)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(height: 54)
            }
            
            Button {
                presentBoulderProblemsList = true
            } label: {
                HStack(spacing: 4) {
                    let count = mapState.allProblemsCount(for: problem.topoId ?? 0)
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
            if let photo = thumbnailPhotos[topo.id] {
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
    
    private func goToTopo(_ topo: Topo) {
        withAnimation(.easeInOut(duration: 0.25)) {
            mapState.selection = .topo(topo: topo)
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
        .onChange(of: mapState.activeProblemId) { _, _ in
            // Fires on problem-to-problem taps (isInTopoMode stays false so
            // the handler above doesn't run). Silent during topo-to-topo swipes.
            if case .problem(let p, _) = mapState.selection, p.topoId == topo.id, p.id != problem.id {
                problem = p
            }
        }
    }
}

//struct TopoFullScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        TopoFullScreenView()
//    }
//}
