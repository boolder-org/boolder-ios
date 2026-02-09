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
                        
                        if false { // problem.otherProblemsOnSameTopo.count > 1 {
                            HStack(spacing: 0) {
                                Spacer()
                                if #available(iOS 26, *) {
                                    Button(action: {
                                        mapState.showAllLines = true
                                        presentTopoFullScreenView = true
                                    }) {
                                        Image(systemName: "arrow.trianglehead.branch")
                                            .font(.system(size: UIFontMetrics.default.scaledValue(for: 20)))
                                            .padding(2)
                                    }
                                    .buttonStyle(.glass)
                                    .buttonBorderShape(.circle)
                                }
                                else {
                                    Button(action: {
                                        mapState.showAllLines = true
                                        presentTopoFullScreenView = true
                                    }) {
                                        Image(systemName: "arrow.trianglehead.branch")
                                            .foregroundColor(.white)
                                            .font(.system(size: UIFontMetrics.default.scaledValue(for: 20)))
                                            .padding(8)
                                            .background(Color.black.opacity(0.3))
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 4)
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
                        topoNavigationButtons
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
    
    var topoNavigationButtons: some View {
        HStack {
            if let previousTopo = previousTopo {
                Button(action: {
                    goToTopo(previousTopo)
                }) {
                    Label("Previous", systemImage: "chevron.left")
                }
                .modify {
                    if #available(iOS 26, *) {
                        $0.buttonStyle(.glass)
                            .buttonBorderShape(.capsule)
                    } else {
                        $0
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground))
                            .clipShape(Capsule())
                            .shadow(color: Color(.secondaryLabel).opacity(0.5), radius: 5)
                    }
                }
            }
            
            Spacer()
            
            if let nextTopo = nextTopo {
                Button(action: {
                    goToTopo(nextTopo)
                }) {
                    Label("Next", systemImage: "chevron.right")
                        .environment(\.layoutDirection, .rightToLeft)
                }
                .modify {
                    if #available(iOS 26, *) {
                        $0.buttonStyle(.glass)
                            .buttonBorderShape(.capsule)
                    } else {
                        $0
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground))
                            .clipShape(Capsule())
                            .shadow(color: Color(.secondaryLabel).opacity(0.5), radius: 5)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var nextTopo: Topo? {
        guard let topo = problem.topo, let boulderId = topo.boulderId else { return nil }
        return Boulder(id: boulderId).nextTopo(after: topo)
    }
    
    private var previousTopo: Topo? {
        guard let topo = problem.topo, let boulderId = topo.boulderId else { return nil }
        return Boulder(id: boulderId).previousTopo(before: topo)
    }
    
    private func goToTopo(_ topo: Topo) {
        if let topProblem = topo.topProblem {
            mapState.selectProblem(topProblem)
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

