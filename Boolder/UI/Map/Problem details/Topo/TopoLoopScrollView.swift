//
//  TopoLoopScrollView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 18/02/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

/// A paging ScrollView that wraps its items in multiple copies
/// to give the illusion of infinite looping.
///
/// Because `scrollLoopId` lives here instead of in the parent, a page change
/// only re-evaluates this lightweight body – the parent stays untouched until
/// the `onTopoChanged` callback fires (typically deferred via `Task`).
struct TopoLoopScrollView<Content: View>: View {
    private let loopCopies = 3
    private let centerCopy = 1 // loopCopies / 2

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
    @State private var topoById: [Int: Topo] = [:]
    @State private var pendingTopoChangeTask: Task<Void, Never>?
    @State private var recenterTask: Task<Void, Never>?

    private func centerLoopId(for topoId: Int?) -> Int? {
        topoId.map { centerCopy * 1_000_000 + $0 }
    }

    private func rebuildLoopedTopos() {
        topoById = Dictionary(uniqueKeysWithValues: boulderTopos.map { ($0.id, $0) })
        loopedTopos = (0..<loopCopies).flatMap { copy in
            boulderTopos.map { LoopedTopo(topo: $0, copy: copy) }
        }
        TopoImageCache.shared.preload(topos: boulderTopos)
    }

    private func preloadNeighbors(around realId: Int) {
        guard let currentIndex = boulderTopos.firstIndex(where: { $0.id == realId }), !boulderTopos.isEmpty else { return }
        let prevIndex = (currentIndex + boulderTopos.count - 1) % boulderTopos.count
        let nextIndex = (currentIndex + 1) % boulderTopos.count
        TopoImageCache.shared.preload(topos: [boulderTopos[currentIndex], boulderTopos[prevIndex], boulderTopos[nextIndex]])
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
        .scrollClipDisabled()
        .modify {
            if #available(iOS 18.0, *) {
                $0.onScrollPhaseChange { _, newPhase in
                    if newPhase == .idle {
                        guard let currentId = scrollLoopId else { return }
                        let copyIndex = currentId / 1_000_000
                        guard copyIndex != centerCopy else { return }

                        recenterTask?.cancel()
                        recenterTask = Task {
                            try? await Task.sleep(for: .milliseconds(500))
                            guard !Task.isCancelled else { return }
                            let realId = currentId % 1_000_000
                            scrollLoopId = centerLoopId(for: realId)
                        }
                    } else {
                        recenterTask?.cancel()
                    }
                }
            } else {
                $0
            }
        }
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
            preloadNeighbors(around: realId)

            // If we've hit the very first or last item, re-center immediately.
            if newLoopId == loopedTopos.first?.id || newLoopId == loopedTopos.last?.id {
                recenterTask?.cancel()
                scrollLoopId = centerLoopId(for: realId)
                return
            }

            // Commit only the settled topo once small transient scroll updates stop.
            guard realId != topoId, let topo = topoById[realId] else { return }
            pendingTopoChangeTask?.cancel()
            pendingTopoChangeTask = Task {
                try? await Task.sleep(for: .milliseconds(60))
                guard !Task.isCancelled, realId != topoId else { return }
                await MainActor.run {
                    onTopoChanged(topo)
                }
            }
        }
        .onDisappear {
            pendingTopoChangeTask?.cancel()
            pendingTopoChangeTask = nil
            recenterTask?.cancel()
            recenterTask = nil
        }
    }
}

