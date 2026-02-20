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
    
    @Namespace private var topoTransitionNamespace
    
    var body: some View {
        @Bindable var mapState = mapState
        
        VStack {
            GeometryReader { geo in
                VStack(alignment: .leading, spacing: 8) {
                    topoSwipeView(width: geo.size.width)
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
                    
                    if mapState.isInTopoMode {
                        TopoCarouselView(problem: $problem, style: .inline)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        VStack(alignment: .leading) {
                            ProblemInfoView(problem: problem)
                                .padding(.top, 4)
                                .padding(.horizontal)
                            
                            ProblemActionButtonsView(problem: $problem)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: mapState.isInTopoMode)
            }
            
            Spacer()
        }
        .onAppear {
            viewCount += 1
        }
        .onChange(of: mapState.presentTopoFullScreenRequestCount) { _, _ in
            presentTopoFullScreenView = true
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
    
    // MARK: - Topo horizontal swipe
    
    @ViewBuilder
    private func topoSwipeView(width: CGFloat) -> some View {
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
                    topProblem: mapState.topProblem(for: topo.id) ?? Problem.empty
                )
            }
        } else {
            TopoView(
                problem: $problem,
                zoomScale: .constant(1),
                onBackgroundTap: {
                    guard let topo = problem.topo else { return }
                    mapState.selection = .topo(topo: topo)
                }
            )
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
