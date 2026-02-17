//
//  ProblemDetailsView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 25/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import StoreKit
import MapKit

struct ProblemDetailsView: View {
    @AppStorage("problemDetails/viewCount") var viewCount = 0
    @AppStorage("lastVersionPromptedForReview") var lastVersionPromptedForReview = ""
    @Environment(\.requestReview) private var requestReview
    
    @Binding var problem: Problem
    @Environment(MapState.self) private var mapState: MapState
    
    @State private var areaResourcesDownloaded = false
    @State private var presentTopoFullScreenView = false
    @State private var presentBoulderProblemsList = false
    @State private var scrolledTopoId: Int?
    
    @Namespace private var topoTransitionNamespace
    
    var body: some View {
        @Bindable var mapState = mapState
        
        VStack {
            GeometryReader { geo in
                VStack(alignment: .leading, spacing: 8) {
                    topoSwipeView(width: geo.size.width)
                    .frame(width: geo.size.width, height: geo.size.width * 3/4)
                    .clipped()
                    .zIndex(10)
                    .modify {
                        if #available(iOS 18, *) {
                            $0.matchedTransitionSource(id: "topo-\(problem.topoId ?? 0)", in: topoTransitionNamespace)
                        }
                        else {
                            $0
                        }
                    }
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                if value > 1.1 {
                                    presentTopoFullScreenView = true
                                }
                            }
                    )
                    .fullScreenCover(isPresented: $presentTopoFullScreenView) {
                        TopoFullScreenView(problem: $problem)
                            .modify {
                                if #available(iOS 18, *) {
                                    $0.navigationTransition(.zoom(sourceID: "topo-\(problem.topoId ?? 0)", in: topoTransitionNamespace))
                                }
                                else {
                                    $0
                                }
                            }
                    }
                    
                    if mapState.isInTopoMode {
                        topoCarousel
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        VStack(alignment: .leading) {
                            ProblemInfoView(problem: problem)
                                .padding(.top, 4)
                                .padding(.horizontal)
                            
                            ProblemActionButtonsView(problem: $problem)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: mapState.isInTopoMode)
            }
            
            Spacer()
        }
        .onAppear {
            scrolledTopoId = problem.topoId
            viewCount += 1
        }
        .onChange(of: problem.topoId) { _, newTopoId in
            if let newTopoId, scrolledTopoId != newTopoId {
                withAnimation {
                    scrolledTopoId = newTopoId
                }
            }
        }
        // Inspired by https://developer.apple.com/documentation/storekit/requesting-app-store-reviews
        .onChange(of: viewCount) {
            guard let currentAppVersion = Bundle.currentAppVersion else {
                return
            }

            if viewCount >= 100, currentAppVersion != lastVersionPromptedForReview {
                presentReview()
                lastVersionPromptedForReview = currentAppVersion
            }
        }
    }
    
    var topoCarousel: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Button {
                    goToPreviousTopo()
                } label: {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.primary)
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
                        .foregroundColor(.primary)
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
            .sheet(isPresented: $presentBoulderProblemsList) {
                let scrolledBoulderId = mapState.boulderTopos.first(where: { $0.id == scrolledTopoId })?.boulderId
                BoulderProblemsListView(problems: mapState.boulderProblems, boulderId: scrolledBoulderId, currentTopoId: scrolledTopoId)
                    .presentationDetents([.large])
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
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
    
    // MARK: - Topo horizontal swipe
    
    @ViewBuilder
    private func topoSwipeView(width: CGFloat) -> some View {
        if mapState.boulderTopos.count > 1 {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(mapState.boulderTopos) { topo in
                        TopoPageView(
                            topo: topo,
                            topProblem: mapState.topProblem(for: topo.id) ?? Problem.empty,
                            onBackgroundTap: { presentTopoFullScreenView = true }
                        )
                        .containerRelativeFrame(.horizontal)
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
            TopoView(
                problem: $problem,
                zoomScale: .constant(1),
                onBackgroundTap: {
                    presentTopoFullScreenView = true
                }
            )
        }
    }
    
    private func presentReview() {
        Task {
            // Delay for two seconds to avoid interrupting the person using the app.
            try await Task.sleep(for: .seconds(2))
            requestReview()
        }
    }
}

// MARK: - Topo page wrapper (per-page state for LazyHStack)

private struct TopoPageView: View {
    let topo: Topo
    var onBackgroundTap: (() -> Void)?
    
    @State private var problem: Problem
    @Environment(MapState.self) private var mapState
    
    init(topo: Topo, topProblem: Problem, onBackgroundTap: (() -> Void)? = nil) {
        self.topo = topo
        self.onBackgroundTap = onBackgroundTap
        self._problem = State(initialValue: topProblem)
    }
    
    var body: some View {
        TopoView(
            problem: $problem,
            zoomScale: .constant(1),
            onBackgroundTap: onBackgroundTap
        )
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

//struct ProblemDetailsView_Previews: PreviewProvider {
//    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//
//    static var previews: some View {
//        ProblemDetailsView(problem: .constant(dataStore.problems.first!))
//            .environment(\.managedObjectContext, context)
//    }
//}

