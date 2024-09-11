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
    
    var topos: [TopoWithPosition] {
        TopoWithPosition.onBoulder(1703)
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            
            TabView(selection: $currentPage) {
                ForEach(topos) { topo in
                    ZStack {
                        ImprovedTopoView(topo: topo, problem: problem)
//                        Text(problem.localizedName)
                    }
                    .tag(topo.id)
                }
                
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .onChange(of: currentPage) { newPage in
                print("Page turned to: \(newPage)")
                
                let topo = TopoWithPosition.load(id: newPage)
                
                if let first = topo?.problems.first {
                    problem = first
                }
            }
            .onChange(of: problem) { newProblem in
                let currentTopoId = currentPage
                if TopoWithPosition.load(id: currentTopoId)!.problems.contains(newProblem) {
                    print("here")
                }
                else {
                    print("not here")
                    currentPage = newProblem.topoId!
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
