//
//  BoulderView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 11/09/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct Position: Identifiable, Hashable {
    let topoId: Int
    let index: Int
    
    var id: [Int] {
        [topoId, index]
    }
}

struct BoulderView: View {
    @State private var currentPage = 0 // FIXME
    @Binding var problem: Problem
    let boulderId: Int
    
    @ObservedObject var mapState: MapState
    
    @State private var scrollTarget: Position? = nil
    @State private var visibleTopoId: Int? = nil
    
    var topos: [TopoWithPosition] {
        TopoWithPosition.onBoulder(boulderId)
    }
    
    var scrollView: some View {
        if #available(iOS 17.0, *) {
            return ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(-2..<3) { index in
                            ForEach(topos) { topo in
                                ImprovedTopoView(topo: topo, problem: $problem, mapState: mapState)
                                    .id(Position(topoId: topo.id, index: index))
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                //            .safeAreaPadding(.horizontal, 40)
                .onChange(of: scrollTarget) { target in
                    if let target = target {
//                        withAnimation {
                        print("scrolling to \(target)")
                            proxy.scrollTo(target, anchor: .center)
//                        }
                    }
                }
                .onChange(of: problem) { newProblem in
                    scrollTarget = Position(topoId: newProblem.topoId!, index: 1)
                }
                .modify {
                    if #available(iOS 18.0, *) {
                        $0.onScrollPhaseChange { oldPhase, newPhase in
                            if newPhase == .idle {
                                print("changed page")
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    if let visibleTopoId = visibleTopoId {
                                        if let t = TopoWithPosition.load(id: visibleTopoId) {
                                            if let first = t.firstProblemOnTheLeft {
                                                mapState.selectProblem(first)
                                            }
                                        }
                                    }
//                                }
                            }
                        }
                        .onScrollTargetVisibilityChange(idType: TopoWithPosition.ID.self, threshold: 0.5) { array in
                            if let first = array.first {
//                                visibleTopoId = first
//                                paginateToProblemWithScrollView(p: problem)
                            }
                        }
                    } else {
                        $0
                    }
                }
                .task {
                    scrollTarget = Position(topoId: problem.topoId!, index: 0)
                }
            }
        }
        else {
            return EmptyView()
        }
    }
    
    var tabView: some View {
        TabView(selection: $currentPage) {
            ForEach(topos) { topo in
                ZStack {
                    ImprovedTopoView(topo: topo, problem: $problem, mapState: mapState)
//                        Text(problem.localizedName)
                }
                .tag(topo.id)
            }
            
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//            .onChange(of: currentPage) { newPage in
//                print("Page turned to: \(newPage)")
//
//                let topoId = newPage
//                let topo = TopoWithPosition.load(id: topoId)
//
//                // TODO: choose problem on the left
//                if let first = topo?.problems.first {
//                    problem = first
//                }
//            }
        .onChange(of: problem) { newProblem in
            paginateToProblem(p: newProblem)
        }
        .onAppear {
            if let topoId = problem.topoId {
                currentPage = topoId
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            scrollView
//            tabView
        }
        
        .aspectRatio(4/3, contentMode: .fit)
        .background(Color(.imageBackground))
        
    }
    
//    func paginateToProblemWithScrollView(p: Problem) {
//        print("visible : \(visibleTopoId)")
//        print("selected : \(problem.topoId)")
//        if visibleTopoId != problem.topoId {
//            scrollTarget = problem.topoId
//        }
//    }
    
    func paginateToProblem(p: Problem) {
        let currentTopoId = currentPage
        
        if TopoWithPosition.load(id: currentTopoId)!.problems.contains(p) {
            print("here")
        }
        else {
            print("not here")
            let t = TopoWithPosition.load(id: p.topoId!)! // FIXME: no bang
            currentPage = t.id
        }
    }
    
}

//#Preview {
//    BoulderView()
//}
