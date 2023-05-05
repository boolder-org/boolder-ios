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
    @Published private(set) var centerOnProblem: Problem? = nil
    @Published private(set) var selectedArea: Area? = nil
    @Published private(set) var centerOnArea: Area? = nil
    @Published private(set) var selectedCircuit: Circuit? = nil
    @Published var selectedPoi: Poi? = nil
    @Published var filters: Filters = Filters()
    
    @Published var presentProblemDetails = false
    @Published var presentPoiActionSheet = false
    @Published var presentFilters = false
    @Published var presentAreaView = false
    @Published var presentCircuitPicker = false
    @Published var displayCircuitStartButton = false
    
    // TODO: find a better way to trigger map UI refreshes
    @Published private(set) var selectProblemCount = 0
    @Published private(set) var centerOnProblemCount = 0
    @Published private(set) var centerOnAreaCount = 0
    @Published private(set) var selectCircuitCount = 0
    @Published private(set) var centerOnCircuitCount = 0
    @Published var filtersRefreshCount = 0
    @Published private(set) var centerOnCurrentLocationCount = 0
    
    func centerOnArea(_ area: Area) {
        centerOnArea = area
        centerOnAreaCount += 1
    }
    
    func selectArea(_ area: Area) {
        selectedArea = area
    }
    
    func unselectArea() {
        selectedArea = nil
    }
    
    func selectAndCenterOnCircuit(_ circuit: Circuit) {
        selectedCircuit = circuit
        selectCircuitCount += 1
        centerOnCircuitCount += 1
    }
    
    func selectCircuit(_ circuit: Circuit) {
        selectedCircuit = circuit
        selectCircuitCount += 1
    }
    
    func unselectCircuit() {
        selectedCircuit = nil
        selectCircuitCount += 1
    }
    
    var canGoToNextCircuitProblem: Bool {
        selectedProblem.next != nil
    }
    
    func goToNextCircuitProblem() {
        if let circuit = selectedCircuit {
            if !selectedProblem.circuitNumber.isEmpty && selectedProblem.circuitId == circuit.id {
                if let next = selectedProblem.next {
                    selectAndPresentAndCenterOnProblem(next)
                }
            }
            else {
                if let problem = circuit.firstProblem {
                    selectAndPresentAndCenterOnProblem(problem)
                }
            }
        }
    }
    
    var canGoToPreviousCircuitProblem: Bool {
        selectedProblem.previous != nil
    }
    
    func goToPreviousCircuitProblem() {
        if let circuit = selectedCircuit {
            if !selectedProblem.circuitNumber.isEmpty && selectedProblem.circuitId == circuit.id {
                if let previous = selectedProblem.previous {
                    selectAndPresentAndCenterOnProblem(previous)
                }
            }
            else {
                // not sure what to do here
                if let problem = circuit.firstProblem {
                    selectAndPresentAndCenterOnProblem(problem)
                }
            }
        }
    }
    
    private func centerOnProblem(_ problem: Problem) {
        centerOnProblem = problem
        centerOnProblemCount += 1
    }
    
    // TODO: check if problem is hidden because of the grade filter (in which case, should we clear the filter?)
    func selectProblem(_ problem: Problem) {
        selectedProblem = problem
        selectProblemCount += 1
        
        selectedArea = Area.load(id: problem.areaId)
    }
    
    func selectAndPresentAndCenterOnProblem (_ problem: Problem) {
        centerOnProblem(problem)
        
        var wait = 0.1
        if #available(iOS 15, *) { }
        else {
            wait = 1.0 // weird bug with iOS 14 https://stackoverflow.com/questions/63293531/swiftui-crash-sheetbridge-abandoned-presentation-detected-when-dismiss-a-she
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + wait) { [self] in
            self.selectProblem(problem)
            self.presentProblemDetails = true
        }
    }
    
    func centerOnCurrentLocation() {
        centerOnCurrentLocationCount += 1
    }
    
    func clearFilters() {
        filters = Filters()
        filters.favorite = false
        filtersRefresh()
    }
    
    func filtersRefresh() {
        filtersRefreshCount += 1
    }
}
