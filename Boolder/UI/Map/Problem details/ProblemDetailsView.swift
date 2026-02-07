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
    @State private var showAllLinesInFullScreen = false
    
    // Pagination state
    @State private var toposOnBoulder: [Topo] = []
    @State private var extendedToposList: [ExtendedTopo] = []
    @State private var scrollPosition: Int?
    @State private var isAdjustingScroll = false
    @State private var showPaginationIndicator = true
    @State private var hideIndicatorTask: Task<Void, Never>?
    
    @Namespace private var topoTransitionNamespace
    
    // Struct for extended topos to avoid tuple overhead
    struct ExtendedTopo: Identifiable {
        let id: Int
        let topo: Topo
    }
    
    // Build extended topos list for infinite scroll
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
        guard let topo = problem.topo else { return 1 }
        return (toposOnBoulder.firstIndex(of: topo) ?? 0) + 1
    }
    
    private var currentTopoIndex: Int {
        guard let topo = problem.topo else { return 0 }
        return toposOnBoulder.firstIndex(of: topo) ?? 0
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
                                                    showAllLines: .constant(false),
                                                    onBackgroundTap: {
                                                        showAllLinesInFullScreen = false
                                                        presentTopoFullScreenView = true
                                                    },
                                                    displayedTopo: item.topo
                                                )
                                                .frame(width: geo.size.width, height: geo.size.width * 3/4)
                                                .id(item.id)
                                            }
                                        }
                                        .scrollTargetLayout()
                                    }
                                    .scrollTargetBehavior(.paging)
                                    .scrollPosition(id: $scrollPosition)
                                    .onChange(of: scrollPosition) { oldValue, newValue in
                                        guard !isAdjustingScroll, let newPosition = newValue else { return }
                                        
                                        let count = toposOnBoulder.count
                                        
                                        // Show indicator and schedule hide
                                        showIndicatorTemporarily()
                                        
                                        // Handle navigation to a new topo
                                        if let oldPos = oldValue, oldPos != newPosition {
                                            // Determine direction and select appropriate problem
                                            if newPosition > oldPos || (oldPos == count && newPosition == count + 1) {
                                                // Swiped left (going to next/right topo) -> select first problem
                                                if newPosition >= 1 && newPosition <= count {
                                                    let topo = toposOnBoulder[newPosition - 1]
                                                    if let firstProblem = Problem.onTopo(topo.id).first {
                                                        mapState.selectProblem(firstProblem)
                                                    }
                                                }
                                            } else {
                                                // Swiped right (going to previous/left topo) -> select last problem
                                                if newPosition >= 1 && newPosition <= count {
                                                    let topo = toposOnBoulder[newPosition - 1]
                                                    if let lastProblem = Problem.onTopo(topo.id).last {
                                                        mapState.selectProblem(lastProblem)
                                                    }
                                                }
                                            }
                                        }
                                        
                                        // Handle infinite loop jump
                                        if newPosition == 0 {
                                            // Scrolled to fake last item -> jump to real last
                                            isAdjustingScroll = true
                                            // Select last problem on last topo
                                            if let lastTopo = toposOnBoulder.last,
                                               let lastProblem = Problem.onTopo(lastTopo.id).last {
                                                mapState.selectProblem(lastProblem)
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                var transaction = Transaction()
                                                transaction.disablesAnimations = true
                                                withTransaction(transaction) {
                                                    proxy.scrollTo(count, anchor: .center)
                                                    scrollPosition = count
                                                }
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                                    isAdjustingScroll = false
                                                }
                                            }
                                        } else if newPosition == count + 1 {
                                            // Scrolled to fake first item -> jump to real first
                                            isAdjustingScroll = true
                                            // Select first problem on first topo
                                            if let firstTopo = toposOnBoulder.first,
                                               let firstProblem = Problem.onTopo(firstTopo.id).first {
                                                mapState.selectProblem(firstProblem)
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
                                        }
                                    }
                                }
                                
                                // Page indicator dots
                                VStack {
                                    HStack(spacing: 8) {
                                        ForEach(0..<toposOnBoulder.count, id: \.self) { index in
                                            Circle()
                                                .fill(index == currentTopoIndex ? Color.primary : Color.primary.opacity(0.3))
                                                .frame(width: 8, height: 8)
                                        }
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 10)
                                    .background(.ultraThinMaterial, in: Capsule())
                                    .padding(.top, 8)
                                    .opacity(showPaginationIndicator ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.3), value: showPaginationIndicator)
                                    
                                    Spacer()
                                }
                            }
                            .frame(width: geo.size.width, height: geo.size.width * 3/4)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        if value > 1.1 {
                                            showAllLinesInFullScreen = false
                                            presentTopoFullScreenView = true
                                        }
                                    }
                            )
                        } else {
                            TopoView(
                                problem: $problem,
                                zoomScale: .constant(1),
                                showAllLines: .constant(false),
                                onBackgroundTap: {
                                    showAllLinesInFullScreen = false
                                    presentTopoFullScreenView = true
                                }
                            )
                            .frame(width: geo.size.width, height: geo.size.width * 3/4)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        if value > 1.1 {
                                            showAllLinesInFullScreen = false
                                            presentTopoFullScreenView = true
                                        }
                                    }
                            )
                        }
                    }
                    .modify {
                        if #available(iOS 18, *) {
                            $0.matchedTransitionSource(id: "topo-\(problem.topoId ?? 0)", in: topoTransitionNamespace)
                        }
                        else {
                            $0
                        }
                    }
                    .fullScreenCover(isPresented: $presentTopoFullScreenView) {
                        TopoFullScreenView(problem: $problem, showAllLines: $showAllLinesInFullScreen)
                            .modify {
                                if #available(iOS 18, *) {
                                    $0.navigationTransition(.zoom(sourceID: "topo-\(problem.topoId ?? 0)", in: topoTransitionNamespace))
                                }
                                else {
                                    $0
                                }
                            }
                    }
                    .zIndex(10)
                    
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
            setupPagination()
        }
        .onChange(of: problem) { oldValue, newValue in
            // Update pagination when problem changes (e.g., from map selection)
            if oldValue.topo?.boulderId != newValue.topo?.boulderId {
                setupPagination()
            } else if !isAdjustingScroll && oldValue.topoId != newValue.topoId {
                // Same boulder but different topo, update scroll position
                scrollPosition = realIndexForCurrentTopo
                showIndicatorTemporarily()
            }
            // If same topo (e.g., tapping a circle on same topo), don't change scroll position
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
    
    private func setupPagination() {
        if let topo = problem.topo {
            toposOnBoulder = topo.onSameBoulder
            extendedToposList = Self.buildExtendedTopos(from: toposOnBoulder)
            scrollPosition = realIndexForCurrentTopo
            showIndicatorTemporarily()
        }
    }
    
    private func showIndicatorTemporarily() {
        // Cancel any pending hide task
        hideIndicatorTask?.cancel()
        
        // Show the indicator
        showPaginationIndicator = true
        
        // Schedule hide after 2 seconds
        hideIndicatorTask = Task {
            try? await Task.sleep(for: .seconds(2))
            if !Task.isCancelled {
                await MainActor.run {
                    showPaginationIndicator = false
                }
            }
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

