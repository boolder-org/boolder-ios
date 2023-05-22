//
//  AppState.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 16/04/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

// Careful: the whole app is redrawn when these properties are changed => big hit on performance, use only when there is no other way
@MainActor class AppState: ObservableObject {
    @Published var tab = Tab.map
    @Published var selectedProblem: Problem?
    @Published var selectedArea: Area?
    @Published var selectedCircuit: CircuitWithArea?
    @Published var badgeClimbingBusWasSeen = UserDefaults.standard.bool(forKey: "climbing-bus-badge-was-seen")
    
    struct CircuitWithArea: Equatable {
        let circuit: Circuit
        let area: Area
    }
    
    enum Tab {
        case map
        case discover
        case bus
        case ticklist
    }
}
