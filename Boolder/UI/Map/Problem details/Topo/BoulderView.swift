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
    
    @ObservedObject var mapState: MapState
    
    var topos: [TopoWithPosition] {
        TopoWithPosition.onBoulder(boulderId)
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            
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
        }
        .aspectRatio(4/3, contentMode: .fit)
        .background(Color(.imageBackground))
//        .onAppear {
//            paginateToProblem()
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
