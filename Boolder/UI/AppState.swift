//
//  AppState.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 16/04/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

@MainActor class AppState: ObservableObject {
    @Published var tab = Tab.map
    @Published var selectedProblem: Problem?
    @Published var selectedArea: Area?
    @Published var selectedCircuit: CircuitWithArea?
    
    struct CircuitWithArea: Equatable {
        let circuit: Circuit
        let area: Area
    }
    
    enum Tab {
        case map
        case discover
        case ticklist
    }
}
