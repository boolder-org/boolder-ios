//
//  AppState.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 16/04/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

@Observable
@MainActor class AppState {
    var tab = Tab.map
    var selectedProblem: Problem?
    var selectedArea: Area?
    var selectedCircuit: CircuitWithArea?
    
    struct CircuitWithArea: Equatable {
        let circuit: Circuit
        let area: Area
    }
    
    enum Tab {
        case map
        case discover
        case ticklist
        case contribute
    }
}
