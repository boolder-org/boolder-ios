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
    let navigateToTopoId: Int?
    let onNavigationHandled: () -> Void
    let onTopoChanged: (Topo) -> Void
    @ViewBuilder let content: (Topo) -> Content

    // MARK: - Internal state

    private struct LoopedTopoId: Hashable {
        let copy: Int
        let topoId: Int
    }

    private struct LoopedTopo: Identifiable {
        let topo: Topo
        let copy: Int
        var id: LoopedTopoId { LoopedTopoId(copy: copy, topoId: topo.id) }
    }

    @State private var scrollLoopId: LoopedTopoId?
    @State private var loopedTopos: [LoopedTopo] = []
    @State private var lastSeenBoulderId: Int?
    @State private var topoById: [Int: Topo] = [:]
    @State private var pendingTopoChangeTask: Task<Void, Never>?

    private func centerLoopId(for topoId: Int?) -> LoopedTopoId? {
        topoId.map { LoopedTopoId(copy: centerCopy, topoId: $0) }
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
                    guard newPhase == .idle, let currentId = scrollLoopId else { return }
                    let isAtEdge = currentId == loopedTopos.first?.id || currentId == loopedTopos.last?.id
                    guard isAtEdge else { return }
                    scrollLoopId = centerLoopId(for: currentId.topoId)
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
            let currentRealId = scrollLoopId?.topoId
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
        .onChange(of: navigateToTopoId) { _, newId in
            guard let newId else { return }
            withAnimation {
                scrollLoopId = centerLoopId(for: newId)
            }
            onNavigationHandled()
        }
        .onChange(of: scrollLoopId) { oldLoopId, newLoopId in
            guard let newLoopId else { return }
            let realId = newLoopId.topoId
            preloadNeighbors(around: realId)

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
        }
    }
}

