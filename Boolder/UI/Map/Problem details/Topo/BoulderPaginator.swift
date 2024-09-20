//
//  BoulderPaginator.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 18/09/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import Foundation
import SwiftUI

class BoulderPaginator: ObservableObject {
    let boulderId: Int
    let topos: [TopoWithSelection]
//    @Published var
    
    init(boulderId: Int) {
        self.boulderId = boulderId
        self.topos = TopoWithPosition.onBoulder(boulderId).map{ TopoWithSelection(topo: $0) }
    }
    
    
}

struct TopoWithSelection {
    let topo: TopoWithPosition
//    let defaultProblem: Problem? = nil
    let userSelectedProblem: Problem? = nil
    
    
}
