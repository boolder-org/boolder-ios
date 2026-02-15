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
    
    @Namespace private var topoTransitionNamespace
    
    var body: some View {
        @Bindable var mapState = mapState
        
        VStack {
            GeometryReader { geo in
                VStack(alignment: .leading, spacing: 8) {
                    ZStack(alignment: .top) {
                        TopoView(
                            problem: $problem,
                            zoomScale: .constant(1),
                            showAllLines: $mapState.showAllLines,
                            onBackgroundTap: {
                                presentTopoFullScreenView = true
                            }
                        )
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
                        
                    }
                    .frame(width: geo.size.width, height: geo.size.width * 3/4)
                    .zIndex(10)
                    
                    if !mapState.showAllLines {
                        VStack(alignment: .leading) {
                            ProblemInfoView(problem: problem)
                                .padding(.top, 4)
                                .padding(.horizontal)
                            
                            ProblemActionButtonsView(problem: $problem)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        topoCarousel
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: mapState.showAllLines)
            }
            
            Spacer()
        }
        .onAppear {
            viewCount += 1
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
                    let count = CGFloat(boulderTopos.count)
                    let totalSpacing = 8 * max(count - 1, 0)
                    let thumbnailWidth = min(72, max(0, (geo.size.width - totalSpacing) / max(count, 1)))
                    
                    HStack(spacing: 8) {
                        ForEach(Array(boulderTopos.enumerated()), id: \.element.id) { index, topo in
                            topoThumbnail(topo: topo, isCurrent: topo.id == problem.topoId, width: thumbnailWidth, index: index)
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
                    Text(String(format: NSLocalizedString((problem.topo?.allProblems.count ?? 0) == 1 ? "boulder.info_basic_singular" : "boulder.info_basic", comment: ""), problem.topo?.allProblems.count ?? 0))
                    Image(systemName: "chevron.right")
                }
                .font(.callout)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(Color.gray, lineWidth: 1)
//                )
            }
            .sheet(isPresented: $presentBoulderProblemsList) {
                BoulderProblemsListView(problems: boulderProblems, boulderId: problem.topo?.boulderId, currentTopoId: problem.topoId)
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
    
    private var boulderTopos: [Topo] {
        guard let topo = problem.topo, let boulderId = topo.boulderId else { return [] }
        return Boulder(id: boulderId).topos
    }
    
    private var boulderProblems: [Problem] {
        guard let topo = problem.topo, let boulderId = topo.boulderId else { return [] }
        return Boulder(id: boulderId).problems
    }
    
    private func goToTopo(_ topo: Topo) {
        if let topProblem = topo.topProblem {
            mapState.selectProblem(topProblem, showAllLines: true)
        }
    }
    
    private func goToPreviousTopo() {
        guard let topo = problem.topo, let boulderId = topo.boulderId,
              let previous = Boulder(id: boulderId).previousTopo(before: topo) else { return }
        goToTopo(previous)
    }
    
    private func goToNextTopo() {
        guard let topo = problem.topo, let boulderId = topo.boulderId,
              let next = Boulder(id: boulderId).nextTopo(after: topo) else { return }
        goToTopo(next)
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

