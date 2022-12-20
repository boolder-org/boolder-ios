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
    @Published private(set) var selectProblemCount = 0 // to update the map UI without redrawing everything
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
    
    @Published var selectedArea: Area? = nil
    @Published var selectedCircuit: Circuit? = nil
    @Published private(set) var selectCircuitCount = 0
    
    
    func centerOnArea(_ area: Area) {
        centerOnArea = area
        centerOnAreaCount += 1
    }
    
    func selectArea(_ area: Area) {
        selectedArea = area
    }
    
    func selectAndCenterOnCircuit(_ circuit: Circuit) {
        selectedCircuit = circuit
        selectCircuitCount += 1
    }
    
    func unselectCircuit() {
        selectedCircuit = nil
        selectCircuitCount += 1
    }
    
    func goToNextCircuitProblem() {
        if let circuit = selectedCircuit {
            // TODO: use a separate property to store the selected problem within the circuit (to be able to come back to it easily)
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
    
    private func centerOnProblem(_ problem: Problem) {
        centerOnProblem = problem
        centerOnProblemCount += 1
    }
    
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.selectedArea = Area.load(id: problem.areaId)
            }
        }
    }
    
    func centerOnCurrentLocation() {
        centerOnCurrentLocationCount += 1
    }
    
    func filtersRefresh() {
        filtersRefreshCount += 1
    }
}
