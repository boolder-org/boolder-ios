//
//  TopoCarouselView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 20/02/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TopoCarouselView: View {
    let problem: Problem
    let style: Style
    
    enum Style {
        case inline
        case overlay
    }
    
    @Environment(MapState.self) private var mapState
    @State private var presentBoulderProblemsList = false
    @State private var lastSeenBoulderId: Int?
    @State private var thumbnailPhotos: [Int: UIImage] = [:]
    @State private var thumbnailTask: Task<Void, Never>?
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                GeometryReader { geo in
                    let count = CGFloat(mapState.boulderTopos.count)
                    let totalSpacing = 8 * max(count - 1, 0)
                    let thumbnailWidth = min(72, max(0, (geo.size.width - totalSpacing) / max(count, 1)))
                    
                    HStack(spacing: 8) {
                        ForEach(mapState.boulderTopos, id: \.id) { topo in
                            topoThumbnail(topo: topo, isCurrent: topo.id == problem.topoId, width: thumbnailWidth)
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
                    let count = mapState.problemsCount(for: problem.topoId ?? 0)
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
        .modify {
            if style == .overlay {
                $0.padding(.vertical, 16)
                    .background(.regularMaterial)
                    .padding(.bottom)
                    .safeAreaPadding(.bottom)
            } else {
                $0.padding(.top, 8)
            }
        }
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
    
    // MARK: - Thumbnails
    
    @ViewBuilder
    private func topoThumbnail(topo: Topo, isCurrent: Bool, width: CGFloat) -> some View {
        Button {
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
    }
    
    private func goToTopo(_ topo: Topo) {
        withAnimation(.easeInOut(duration: 0.25)) {
            mapState.selectTopo(topo)
        }
    }
    
    private func buildThumbnailPhotos() {
        let topos = mapState.boulderTopos
        thumbnailTask?.cancel()
        thumbnailTask = Task(priority: .utility) {
            var photos: [Int: UIImage] = [:]
            var missingTopos: [Topo] = []
            
            // First pass: load from cache/disk
            for topo in topos {
                if Task.isCancelled { return }
                if let image = await TopoImageCache.shared.image(for: topo) {
                    photos[topo.id] = image
                } else {
                    missingTopos.append(topo)
                }
            }
            if Task.isCancelled { return }
            await MainActor.run {
                thumbnailPhotos = photos
            }
            
            // Second pass: download missing photos and update thumbnails as they arrive
            for topo in missingTopos {
                if Task.isCancelled { return }
                let result = await Downloader().downloadFile(topo: topo)
                if result == .success, let image = await TopoImageCache.shared.image(for: topo) {
                    if Task.isCancelled { return }
                    await MainActor.run {
                        thumbnailPhotos[topo.id] = image
                    }
                }
            }
        }
    }
}

