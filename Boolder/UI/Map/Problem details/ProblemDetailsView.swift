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
    @State private var showAllLines = false
    
    // Pagination state
    @State private var currentTopo: Topo?
    @State private var toposOnBoulder: [Topo] = []
    @State private var extendedToposList: [ExtendedTopo] = []
    @State private var scrollPosition: Int?
    @State private var isAdjustingScroll = false
    @State private var idleTask: Task<Void, Never>?
    
    @Namespace private var topoTransitionNamespace
    
    struct ExtendedTopo: Identifiable {
        let id: Int
        let topo: Topo
    }
    
    private static func buildExtendedTopos(from topos: [Topo]) -> [ExtendedTopo] {
        guard topos.count > 1 else { return [] }
        
        var result: [ExtendedTopo] = []
        
        // Add last topo as first (fake, for looping backward)
        result.append(ExtendedTopo(id: 0, topo: topos.last!))
        
        // Add all real topos
        for (index, topo) in topos.enumerated() {
            result.append(ExtendedTopo(id: index + 1, topo: topo))
        }
        
        // Add first topo as last (fake, for looping forward)
        result.append(ExtendedTopo(id: topos.count + 1, topo: topos.first!))
        
        return result
    }
    
    private var realIndexForCurrentTopo: Int {
        guard let currentTopo = currentTopo else { return 1 }
        return (toposOnBoulder.firstIndex(of: currentTopo) ?? 0) + 1
    }
    
    private var currentTopoIndex: Int {
        guard let currentTopo = currentTopo else { return 0 }
        return toposOnBoulder.firstIndex(of: currentTopo) ?? 0
    }
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                VStack(alignment: .leading, spacing: 8) {
                    ZStack(alignment: .top) {
                        if !extendedToposList.isEmpty {
                            ZStack {
                                ScrollViewReader { proxy in
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        LazyHStack(spacing: 0) {
                                            ForEach(extendedToposList) { item in
                                                TopoView(
                                                    problem: $problem,
                                                    zoomScale: .constant(1),
                                                    showAllLines: $showAllLines,
                                                    onBackgroundTap: {
                                                        showAllLines = true
                                                    },
                                                    skipInitialBounceAnimation: true,
                                                    displayedTopo: item.topo
                                                )
                                                .containerRelativeFrame(.horizontal)
                                                .id(item.id)
                                            }
                                        }
                                        .scrollTargetLayout()
                                    }
                                    .scrollTargetBehavior(.paging)
                                    .scrollPosition(id: $scrollPosition)
                                    .onChange(of: scrollPosition) { _, newValue in
                                        guard !isAdjustingScroll, let newPosition = newValue else { return }
                                        let count = toposOnBoulder.count
                                        if newPosition >= 1 && newPosition <= count {
                                            currentTopo = toposOnBoulder[newPosition - 1]
                                        } else if newPosition == 0 {
                                            currentTopo = toposOnBoulder.last
                                        } else if newPosition == count + 1 {
                                            currentTopo = toposOnBoulder.first
                                        }
                                    }
                                    .onScrollPhaseChange { _, newPhase in
                                        guard newPhase == .idle, !isAdjustingScroll else { return }
                                        guard let position = scrollPosition else { return }
                                        
                                        let count = toposOnBoulder.count
                                        
                                        if position == 0 {
                                            isAdjustingScroll = true
                                            var transaction = Transaction()
                                            transaction.disablesAnimations = true
                                            withTransaction(transaction) {
                                                proxy.scrollTo(count, anchor: .center)
                                                scrollPosition = count
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                                isAdjustingScroll = false
                                            }
                                        } else if position == count + 1 {
                                            isAdjustingScroll = true
                                            var transaction = Transaction()
                                            transaction.disablesAnimations = true
                                            withTransaction(transaction) {
                                                proxy.scrollTo(1, anchor: .center)
                                                scrollPosition = 1
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                                isAdjustingScroll = false
                                            }
                                        }
                                        
                                        idleTask?.cancel()
                                        idleTask = Task {
                                            try? await Task.sleep(for: .seconds(0.2))
                                            guard !Task.isCancelled else { return }
                                            selectProblemForCurrentTopo()
                                        }
                                    }
                                }
                                
                            }
                        } else {
                            TopoView(
                                problem: $problem,
                                zoomScale: .constant(1),
                                showAllLines: $showAllLines,
                                onBackgroundTap: {
                                    showAllLines = true
                                }
                            )
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.width * 3/4)
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
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 30)
                            .onEnded { value in
                                if value.translation.height < -50 && abs(value.translation.height) > abs(value.translation.width) {
                                    presentTopoFullScreenView = true
                                }
                            }
                    )
                    .fullScreenCover(isPresented: $presentTopoFullScreenView) {
                        TopoFullScreenView(problem: $problem, showAllLines: $showAllLines)
                            .modify {
                                if #available(iOS 18, *) {
                                    $0.navigationTransition(.zoom(sourceID: "topo-\(problem.topoId ?? 0)", in: topoTransitionNamespace))
                                }
                                else {
                                    $0
                                }
                            }
                    }
                    
                    ProblemInfoView(problem: problem)
                        .padding(.top, 4)
                        .padding(.horizontal)
                    
                    ProblemActionButtonsView(problem: $problem)
                }
            }
            
            Spacer()
        }
        .onAppear {
            viewCount += 1
            setupTopos()
        }
        .onChange(of: problem) { oldValue, newValue in
            if oldValue.topo?.boulderId != newValue.topo?.boulderId {
                // Different boulder: rebuild the entire topo list
                setupTopos()
            } else if oldValue.topoId != newValue.topoId {
                // Same boulder, different topo: scroll to the right page
                currentTopo = newValue.topo
                scrollPosition = realIndexForCurrentTopo
            }
        }
        .onChange(of: mapState.requestTopoFullScreen) { _, newValue in
            if newValue {
                presentTopoFullScreenView = true
                mapState.requestTopoFullScreen = false
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
    
    private func setupTopos() {
        currentTopo = problem.topo
        if let topo = problem.topo {
            toposOnBoulder = topo.onSameBoulder
            extendedToposList = Self.buildExtendedTopos(from: toposOnBoulder)
            scrollPosition = realIndexForCurrentTopo
        } else {
            toposOnBoulder = []
            extendedToposList = []
            scrollPosition = nil
        }
    }
    
    private func selectProblemForCurrentTopo() {
        guard let topo = currentTopo else { return }
        
        if problem.topoId == topo.id {
            return
        }
        
        let problems = Problem.onTopo(topo.id)
        if let best = problems.max(by: { $0.zIndex < $1.zIndex }) {
            mapState.selectProblem(best)
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


//struct ProblemDetailsView_Previews: PreviewProvider {
//    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//
//    static var previews: some View {
//        ProblemDetailsView(problem: .constant(dataStore.problems.first!))
//            .environment(\.managedObjectContext, context)
//    }
//}
