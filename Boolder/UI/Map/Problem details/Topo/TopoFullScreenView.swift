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
    @Binding var showAllLines: Bool
    
    @State private var zoomScale: CGFloat = 1
    @State private var currentTopo: Topo?
    @State private var toposOnBoulder: [Topo] = []
    @State private var extendedToposList: [ExtendedTopo] = []
    @State private var scrollPosition: Int?
    @State private var isAdjustingScroll = false
    @State private var isZoomedIn = false
    @State private var idleTask: Task<Void, Never>?
    
    // drag gesture (to dismiss the sheet)
    @State var dragOffset: CGSize = .zero
    @State var dragOffsetPredicted: CGSize = .zero
    
    // Struct for extended topos to avoid tuple overhead
    struct ExtendedTopo: Identifiable {
        let id: Int
        let topo: Topo
    }
    
    private var boulder: Boulder? {
        guard let boulderId = problem.topo?.boulderId else { return nil }
        return Boulder(id: boulderId)
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
        guard let currentTopo = currentTopo else { return 1 }
        return (toposOnBoulder.firstIndex(of: currentTopo) ?? 0) + 1
    }
    
    private var currentTopoIndex: Int {
        guard let currentTopo = currentTopo else { return 0 }
        return toposOnBoulder.firstIndex(of: currentTopo) ?? 0
    }
    
    var body: some View {
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
                    
                    if !showAllLines {                        
                        overlayInfos
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: showAllLines)
                .edgesIgnoringSafeArea(.bottom)
                .zIndex(2)
                
                if !extendedToposList.isEmpty {
                    ZStack {
                        ScrollViewReader { proxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 0) {
                                    ForEach(extendedToposList) { item in
                                        TopoPageView(
                                            problem: $problem,
                                            showAllLines: $showAllLines,
                                            topo: item.topo,
                                            onZoomChanged: { zoomed in
                                                isZoomedIn = zoomed
                                            }
                                        )
                                        .containerRelativeFrame(.horizontal)
                                        .id(item.id)
                                    }
                                }
                                .scrollTargetLayout()
                            }
                            .scrollTargetBehavior(.paging)
                            .scrollPosition(id: $scrollPosition)
                            .scrollDisabled(isZoomedIn)
                            .onChange(of: scrollPosition) { _, newValue in
                                // Lightweight: only update currentTopo for the page indicator dots
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
                                // Wait until scrolling is fully done before doing any heavy work
                                guard newPhase == .idle, !isAdjustingScroll else { return }
                                guard let position = scrollPosition else { return }
                                
                                let count = toposOnBoulder.count
                                
                                // Handle infinite loop jumps (fake boundary pages) — must be immediate
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
                                
                                // Defer problem selection until idle for 0.5s
                                // so rapid pagination doesn't trigger repeated heavy UI updates
                                idleTask?.cancel()
                                idleTask = Task {
                                    try? await Task.sleep(for: .seconds(0.1))
                                    guard !Task.isCancelled else { return }
                                    if !showAllLines {
                                        selectProblemForCurrentTopo()
                                    }
                                }
                            }
                        }
                        
                        // Page indicator dots
                        VStack {
                            Spacer()
                            HStack(spacing: 8) {
                                ForEach(0..<toposOnBoulder.count, id: \.self) { index in
                                    Circle()
                                        .fill(index == currentTopoIndex ? Color.primary : Color.primary.opacity(0.3))
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(.ultraThinMaterial, in: Capsule())
                            .padding(.bottom, 32)
                        }
                        .safeAreaPadding(.bottom)
                    }
                    .containerRelativeFrame(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .zIndex(1)
                    .offset(x: 0, y: self.dragOffset.height)
                    .background(Color.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                } else {
                    ZoomableScrollView(zoomScale: $zoomScale) {
                        TopoView(problem: $problem, zoomScale: $zoomScale, showAllLines: $showAllLines, onBackgroundTap: {
                            if !showAllLines && problem.otherProblemsOnSameTopo.count > 1 {
                                showAllLines = true
                            }
                        }, skipInitialBounceAnimation: true)
                    }
                    .containerRelativeFrame(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .zIndex(1)
                    .offset(x: 0, y: self.dragOffset.height)
                    .background(Color.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                }
                
            }
            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            currentTopo = problem.topo
            if let topo = problem.topo {
                toposOnBoulder = topo.onSameBoulder
                extendedToposList = Self.buildExtendedTopos(from: toposOnBoulder)
                // Set initial scroll position immediately to avoid flash
                scrollPosition = realIndexForCurrentTopo
            }
        }
    }
    
    /// When showAllLines is false, ensure the displayed problem matches the current topo.
    /// If the current problem is on this topo, keep it. Otherwise, select the problem with the highest zIndex.
    private func selectProblemForCurrentTopo() {
        guard let topo = currentTopo else { return }
        
        // Current problem is already on this topo — keep it
        if problem.topoId == topo.id {
            return
        }
        
        // Otherwise, pick the problem with the highest zIndex on this topo
        let problems = Problem.onTopo(topo.id)
        if let best = problems.max(by: { $0.zIndex < $1.zIndex }) {
            mapState.selectProblem(best)
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

// MARK: - TopoPageView
// Separate view for each page with its own zoom state to avoid performance issues
private struct TopoPageView: View {
    @Binding var problem: Problem
    @Binding var showAllLines: Bool
    let topo: Topo
    let onZoomChanged: (Bool) -> Void
    
    @State private var zoomScale: CGFloat = 1
    
    var body: some View {
        ZoomableScrollView(zoomScale: $zoomScale) {
            TopoView(
                problem: $problem,
                zoomScale: $zoomScale,
                showAllLines: $showAllLines,
                onBackgroundTap: {
                    if !showAllLines && problem.otherProblemsOnSameTopo.count > 1 {
                        showAllLines = true
                    }
                },
                skipInitialBounceAnimation: true,
                displayedTopo: topo
            )
        }
        .onChange(of: zoomScale) { oldValue, newValue in
            let isZoomed = newValue > 1.01
            let wasZoomed = oldValue > 1.01
            if isZoomed != wasZoomed {
                onZoomChanged(isZoomed)
            }
        }
    }
}

//struct TopoFullScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        TopoFullScreenView()
//    }
//}
