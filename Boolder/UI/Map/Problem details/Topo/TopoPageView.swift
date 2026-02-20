//
//  TopoPageView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 20/02/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

/// A per-page topo wrapper for use inside `TopoLoopScrollView`.
///
/// Each page owns its own `@State problem` so that page changes don't
/// re-render sibling pages. When `zoomable` is true the topo is wrapped
/// in a `ZoomableScrollView`.
struct TopoPageView: View {
    let topo: Topo
    let zoomable: Bool
    let backgroundTapTogglesMode: Bool
    
    @State private var problem: Problem
    @State private var zoomScale: CGFloat = 1
    @Environment(MapState.self) private var mapState
    
    init(topo: Topo, topProblem: Problem, zoomable: Bool = false, backgroundTapTogglesMode: Bool = false) {
        self.topo = topo
        self.zoomable = zoomable
        self.backgroundTapTogglesMode = backgroundTapTogglesMode
        self._problem = State(initialValue: topProblem)
    }
    
    var body: some View {
        topoContent
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
    
    @ViewBuilder
    private var topoContent: some View {
        if zoomable {
            ZoomableScrollView(zoomScale: $zoomScale) {
                TopoView(
                    problem: $problem,
                    zoomScale: $zoomScale,
                    onBackgroundTap: backgroundTapAction,
                    skipInitialBounceAnimation: true
                )
            }
        } else {
            TopoView(
                problem: $problem,
                zoomScale: .constant(1),
                onBackgroundTap: backgroundTapAction
            )
        }
    }
    
    private var backgroundTapAction: (() -> Void)? {
        guard backgroundTapTogglesMode else { return nil }
        return {
            if case .problem = mapState.selection, problem.otherProblemsOnSameTopo.count > 1, let topo = problem.topo {
                mapState.selection = .topo(topo: topo)
            }
        }
    }
}

