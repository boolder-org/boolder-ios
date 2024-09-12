//
//  BoulderView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 11/09/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct BoulderView: View {
    @State private var currentPage = 0
    @Binding var problem: Problem
    let boulderId: Int
    
    var topos: [TopoWithPosition] {
        TopoWithPosition.onBoulder(boulderId)
    }
    
    func pageForTopo(_ topo: TopoWithPosition) -> Int? {
        
        let page = topos.firstIndex(of: topo)
        print(page)
        return page
    }
    
    func topoForPage(_ page: Int) -> TopoWithPosition? {
        topos[page]
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            
            TabView(selection: $currentPage) {
                ForEach(topos) { topo in
                    ZStack {
                        ImprovedTopoView(topo: topo, problem: $problem)
//                        Text(problem.localizedName)
                    }
                    .tag(pageForTopo(topo)!)
                }
                
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .onChange(of: currentPage) { newPage in
                print("Page turned to: \(newPage)")
                
                let topo = topoForPage(newPage)
                
                // TODO: choose problem on the left
                if let first = topo?.problems.first {
                    problem = first
                }
            }
            .onChange(of: problem) { newProblem in
                guard let currentTopoId = topoForPage(currentPage)?.id else { return }
                
                if TopoWithPosition.load(id: currentTopoId)!.problems.contains(newProblem) {
                    print("here")
                }
                else {
                    print("not here")
                    let t = TopoWithPosition.load(id: newProblem.topoId!)! // FIXME: no bang
                    if let page = pageForTopo(t) {
                        currentPage = page
                    }
                }
            }
        }
        .aspectRatio(4/3, contentMode: .fit)
        .background(Color(.imageBackground))
    }
    
}

//#Preview {
//    BoulderView()
//}
