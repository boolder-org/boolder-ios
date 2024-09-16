//
//  BoulderView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 11/09/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct BoulderView: View {
    @State private var currentPage = 0 // FIXME
    @Binding var problem: Problem
    let boulderId: Int
    
    @ObservedObject var mapState: MapState
    
    @State private var scrollTarget: [Int]? = nil
    @State private var visibleTopoId: Int? = nil
    
    var topos: [TopoWithPosition] {
        TopoWithPosition.onBoulder(boulderId)
    }
    
    var paginableTopos: [PaginableTopoWithPosition] {
        var array = [PaginableTopoWithPosition]()
        array.append(PaginableTopoWithPosition(topo: topos.last!, index: -1))
        array.append(contentsOf: topos.map{PaginableTopoWithPosition(topo: $0, index: 0)})
        array.append(PaginableTopoWithPosition(topo: topos.first!, index: 1))
        return array
        
    }
    
    var scrollView: some View {
        if #available(iOS 17.0, *) {
            return ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(paginableTopos) { topo in
                            ImprovedTopoView(topo: topo, problem: $problem, mapState: mapState)
                                .tag(topo.id)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                //            .safeAreaPadding(.horizontal, 40)
                .onChange(of: scrollTarget) { target in
                    if let target = target {
//                        withAnimation {
                        print("scroll to \(target)")
                            proxy.scrollTo(target, anchor: .center)
//                        }
                    }
                }
                .onChange(of: problem) { newProblem in
//                    scrollTarget = newProblem.topoId
                }
                .modify {
                    if #available(iOS 18.0, *) {
                        $0.onScrollPhaseChange { oldPhase, newPhase in
                            if newPhase == .idle {
                                print("changed page")
//                                print(visibleTopoId)
                                
//                                if let visibleTopoId = visibleTopoId {
//                                    if visibleTopoId == topos.first?.id {
//                                        print("go to last")
//                                        scrollTarget = topos.last?.id
//                                    }
//                                    else if visibleTopoId == topos.last?.id {
//                                        print("go to first")
//                                        scrollTarget = topos.first?.id
//                                    }
//                                }
                                
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    if let visibleTopoId = visibleTopoId {
                                        if let t = TopoWithPosition.load(id: visibleTopoId) {
                                            if let first = t.firstProblemOnTheLeft {
//                                                mapState.selectProblem(first)
                                            }
                                        }
                                    }
//                                }
                            }
                        }
                        .onScrollTargetVisibilityChange(idType: PaginableTopoWithPosition.ID.self, threshold: 0.5) { array in
//                            print(array)
                            if let visibleTopo = array.first {
//                                print(visibleTopo)
                                
                                if visibleTopo[1] == -1 {
                                    print("left")
                                    scrollTarget = [topos.last!.id, 0]
                                }
                                else if visibleTopo[1] == 1 {
                                    print("right")
                                    scrollTarget = [topos.first!.id, 0]
                                }
                                
//                                if first[1] == 0 {
//                                    visibleTopoId = first[0]
//                                }
//                                paginateToProblemWithScrollView(p: problem)
                            }
                            
//                            print("visible = \(visibleTopoId)")
                        }
                    } else {
                        $0
                    }
                }
                .task {
                    if let topoId = problem.topoId {
                        scrollTarget = [topoId, 0]
                    }
                }
            }
        }
        else {
            return EmptyView()
        }
    }
    
//    var tabView: some View {
//        TabView(selection: $currentPage) {
//            ForEach(topos) { topo in
//                ZStack {
//                    ImprovedTopoView(topo: topo, problem: $problem, mapState: mapState)
////                        Text(problem.localizedName)
//                }
//                .tag(topo.id)
//            }
//            
//        }
//        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
////            .onChange(of: currentPage) { newPage in
////                print("Page turned to: \(newPage)")
////
////                let topoId = newPage
////                let topo = TopoWithPosition.load(id: topoId)
////
////                // TODO: choose problem on the left
////                if let first = topo?.problems.first {
////                    problem = first
////                }
////            }
//        .onChange(of: problem) { newProblem in
//            paginateToProblem(p: newProblem)
//        }
//        .onAppear {
//            if let topoId = problem.topoId {
//                currentPage = topoId
//            }
//        }
//    }
    
    var body: some View {
        ZStack(alignment: .center) {
            scrollView
//            tabView
        }
        
        .aspectRatio(4/3, contentMode: .fit)
        .background(Color(.imageBackground))
        
    }
    
    func paginateToProblemWithScrollView(p: Problem) {
        print("visible : \(visibleTopoId)")
        print("selected : \(problem.topoId)")
//        if visibleTopoId != problem.topoId {
//            scrollTarget = problem.topoId
//        }
    }
    
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
