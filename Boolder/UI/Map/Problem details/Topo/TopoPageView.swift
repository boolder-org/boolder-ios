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
    
    @State private var problem: Problem
    @State private var zoomScale: CGFloat = 1
    @Environment(MapState.self) private var mapState
    
    init(topo: Topo, topProblem: Problem, zoomable: Bool = false) {
        self.topo = topo
        self.zoomable = zoomable
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
                    onBackgroundTap: selectTopo,
                    skipInitialBounceAnimation: true
                )
            }
        } else {
            TopoView(
                problem: $problem,
                zoomScale: .constant(1),
                onBackgroundTap: selectTopo
            )
        }
    }
    
    private func selectTopo() {
        guard let topo = problem.topo else { return }
        mapState.selection = .topo(topo: topo)
    }
}

// MARK: - Shared topo swipe content

/// Displays the topo image(s) for the current boulder, either as
/// a looping horizontal scroll (multi-topo) or a single topo view.
/// Set `zoomable` to `true` for the fullscreen presentation.
struct TopoSwipeContentView: View {
    @Binding var problem: Problem
    let zoomable: Bool

    @State private var zoomScale: CGFloat = 1
    @Environment(MapState.self) private var mapState: MapState

    var body: some View {
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
                TopoPageView(
                    topo: topo,
                    topProblem: mapState.topProblem(for: topo.id) ?? Problem.empty,
                    zoomable: zoomable
                )
                .frame(maxHeight: zoomable ? .infinity : nil)
            }
        } else if zoomable {
            ZoomableScrollView(zoomScale: $zoomScale) {
                TopoView(problem: $problem, zoomScale: $zoomScale, onBackgroundTap: selectTopo, skipInitialBounceAnimation: true)
            }
            .containerRelativeFrame(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            TopoView(
                problem: $problem,
                zoomScale: .constant(1),
                onBackgroundTap: selectTopo
            )
        }
    }

    private func selectTopo() {
        guard let topo = problem.topo else { return }
        mapState.selection = .topo(topo: topo)
    }
}

