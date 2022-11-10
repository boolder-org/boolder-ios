//
//  AppState.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 10/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

@MainActor class MapState : ObservableObject {
    @Published var selectedProblem: Problem = Problem.empty // TODO: use nil instead
    @Published var presentProblemDetails = false
    @Published var selectedPoi: Poi? = nil
    @Published var presentPoiActionSheet = false
    @Published var filters: Filters = Filters()
    @Published var presentFilters = false
    @Published private(set) var filtersRefreshCount = 0
    @Published private(set) var centerOnCurrentLocationCount = 0 // to update the map UI without redrawing everything
    @Published private(set) var centerOnProblem: Problem? = nil
    @Published private(set) var centerOnProblemCount = 0 // to update the map UI without redrawing everything
    @Published private(set) var centerOnArea: Area? = nil
    @Published private(set) var centerOnAreaCount = 0 // to update the map UI without redrawing everything
    
    func centerOnArea(_ area: Area) {
        centerOnArea = area
        centerOnAreaCount += 1
    }
    
    func centerOnProblem(_ problem: Problem) {
        centerOnProblem = problem
        centerOnProblemCount += 1
    }
    
    func centerOnCurrentLocation() {
        centerOnCurrentLocationCount += 1
    }
    
    func filtersRefresh() {
        filtersRefreshCount += 1
    }
    
//    @Published var showImageViewer: Bool = true
//    @Published var image = Image("yellow-circuit-start")
}
