//
//  TopoLoopScrollView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 18/02/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

/// A paging ScrollView that wraps its items in 3 copies (before · center · after)
/// to give the illusion of infinite looping.
///
/// Because `scrollLoopId` lives here instead of in the parent, a page change
/// only re-evaluates this lightweight body – the parent stays untouched until
/// the `onTopoChanged` callback fires (typically deferred via `Task`).
struct TopoLoopScrollView<Content: View>: View {
    let boulderTopos: [Topo]
    let topoId: Int?
    let boulderId: Int?
    let onTopoChanged: (Topo) -> Void
    @ViewBuilder let content: (Topo) -> Content

    // MARK: - Internal state

    private struct LoopedTopo: Identifiable {
        let topo: Topo
        let copy: Int
        let id: Int
        init(topo: Topo, copy: Int) {
            self.topo = topo
            self.copy = copy
            self.id = copy * 1_000_000 + topo.id
        }
    }

    @State private var scrollLoopId: Int?
    @State private var loopedTopos: [LoopedTopo] = []
    @State private var lastSeenBoulderId: Int?

    private func centerLoopId(for topoId: Int?) -> Int? {
        topoId.map { 1_000_000 + $0 }
    }

    private func rebuildLoopedTopos() {
        loopedTopos = (0..<3).flatMap { copy in
            boulderTopos.map { LoopedTopo(topo: $0, copy: copy) }
        }
    }

    // MARK: - Body

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(loopedTopos) { item in
                    content(item.topo)
                        .containerRelativeFrame(.horizontal)
                        .id(item.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $scrollLoopId)
        .scrollIndicators(.hidden)
        .onAppear {
            rebuildLoopedTopos()
            scrollLoopId = centerLoopId(for: topoId)
            lastSeenBoulderId = boulderId
        }
        .onChange(of: topoId) { _, newTopoId in
            guard let newTopoId else { return }
            let currentRealId = scrollLoopId.map { $0 % 1_000_000 }
            guard currentRealId != newTopoId else { return }

            if lastSeenBoulderId != boulderId {
                // Boulder changed — rebuild & snap without animation
                lastSeenBoulderId = boulderId
                rebuildLoopedTopos()
                scrollLoopId = centerLoopId(for: newTopoId)
            } else {
                withAnimation {
                    scrollLoopId = centerLoopId(for: newTopoId)
                }
            }
        }
        .onChange(of: scrollLoopId) { _, newLoopId in
            guard let newLoopId else { return }
            let realId = newLoopId % 1_000_000
            // Only call back when the topo actually differs from what the parent knows
            guard realId != topoId,
                  let topo = boulderTopos.first(where: { $0.id == realId })
            else { return }
            onTopoChanged(topo)
        }
    }
}

