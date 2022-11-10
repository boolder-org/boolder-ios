//
//  AppState.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 10/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

@MainActor class AppState : ObservableObject {
    @Published var selectedProblem: Problem = Problem.empty // TODO: use nil instead
    @Published var presentProblemDetails = false
    @Published var presentSearch = false
    @Published var centerOnCurrentLocationCount = 0 // to be able to trigger a map refresh anytime we want
    @Published var centerOnProblem: Problem? = nil
    @Published var centerOnProblemCount = 0 // to be able to trigger a map refresh anytime we want
    @Published var centerOnArea: Area? = nil
    @Published var centerOnAreaCount = 0 // to be able to trigger a map refresh anytime we want
    @Published var selectedPoi: Poi? = nil
    @Published var presentPoiActionSheet = false
    @Published var presentFilters = false
    @Published var filters: Filters = Filters()
    @Published var filtersRefreshCount = 0
    
    @Published var tabSelection = 1
    
//    @Published var showImageViewer: Bool = true
//    @Published var image = Image("yellow-circuit-start")
}
