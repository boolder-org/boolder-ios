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
//    @Published var tab = Tab.map
    @Published var selectedTab = 0
//    @Published var selectedTabCount = 0
    @Published var selectedProblem: Problem?
    @Published var selectedArea: Area?
    @Published var selectedCircuit: CircuitWithArea?
    
    @Published var badgeContributeWasSeen = UserDefaults.standard.bool(forKey: "contribute-badge-was-seen")
    
    func selectTab(tab: Int) {
        selectedTab = tab
//        selectedTabCount = selectedTabCount + 1
//        print(selectedTabCount)
    }
    
    func selectTabMap() {
        selectTab(tab: 0)
    }
    
    struct CircuitWithArea: Equatable {
        let circuit: Circuit
        let area: Area
    }
    
//    enum Tab {
//        case map
//        case discover
//        case ticklist
//        case contribute
//    }
}
