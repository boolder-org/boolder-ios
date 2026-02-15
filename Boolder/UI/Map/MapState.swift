//
//  AppState.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 10/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import CoreLocation

enum ProblemSelectionSource {
    case circleView
    case map
    case other
}

@Observable
class MapState {
    var selectedProblem: Problem = Problem.empty // TODO: use nil instead
    private(set) var selectionSource: ProblemSelectionSource = .other
    private(set) var centerOnProblem: Problem? = nil
    private(set) var selectedArea: Area? = nil
    private(set) var currentLocationCount: Int = 0
    private(set) var center: CLLocationCoordinate2D? = nil
    private(set) var zoom: CGFloat? = nil
    private(set) var centerOnArea: Area? = nil
    private(set) var selectedCluster: Cluster? = nil
    private(set) var selectedCircuit: Circuit? = nil
    private(set) var centerOnCircuit: Circuit? = nil
    private(set) var centerOnBoulderCoordinates: [CLLocationCoordinate2D] = []
    private(set) var centerOnBoulderCount: Int = 0
    var selectedPoi: Poi? = nil
    var filters: Filters = Filters()
    private(set) var refreshFiltersCount: Int = 0
    
    var presentProblemDetails = false
    var presentFilters = false
    var presentAreaView = false
    var presentCircuitPicker = false
    var displayCircuitStartButton = false
    var showAllLines = false
    
    func centerOnArea(_ area: Area) {
        centerOnArea = area
    }
    
    func selectArea(_ area: Area) {
        if area != self.selectedArea {
            selectedArea = area
            
            if let clusterId = area.clusterId, let cluster = Cluster.load(id: clusterId) {
                selectCluster(cluster)
            }
        }
    }
    
    func selectCluster(_ cluster: Cluster) {
        if cluster != self.selectedCluster {
            selectedCluster = cluster
        }
    }
    
    func unselectArea() {
        selectedArea = nil
    }
    
    func unselectCluster() {
        selectedCluster = nil
    }
    
    func selectAndCenterOnCircuit(_ circuit: Circuit) {
        selectedCircuit = circuit
        centerOnCircuit = circuit
    }
    
    func selectCircuit(_ circuit: Circuit) {
        selectedCircuit = circuit
    }
    
    func unselectCircuit() {
        selectedCircuit = nil
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
    }
    
    // TODO: check if problem is hidden because of the grade filter (in which case, should we clear the filter?)
    func selectProblem(_ problem: Problem, source: ProblemSelectionSource = .other) {
        selectedProblem = problem
        selectionSource = source
        
        selectedArea = Area.load(id: problem.areaId)
    }
    
    func selectAndPresentAndCenterOnProblem (_ problem: Problem) {
        centerOnProblem(problem)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            self.selectProblem(problem)
            self.presentProblemDetails = true
        }
    }
    
    func selectBoulder(id: Int) {
        let boulder = Boulder(id: id)
        
        if let topo = boulder.topos.first,
           let problem = topo.problems.first {
            showAllLines = true
            selectProblem(problem, source: .map)
            presentProblemDetails = true
        }
    }
    
    func centerOnBoulder(coordinates: [CLLocationCoordinate2D]) {
        centerOnBoulderCoordinates = coordinates
        centerOnBoulderCount += 1
    }
    
    func centerOnCurrentLocation() {
        currentLocationCount += 1
    }
    
    func clearFilters() {
        filters = Filters()
        filtersRefresh()
    }
    
    func filtersRefresh() {
        refreshFiltersCount += 1
    }
    
    func updateCameraState(center: CLLocationCoordinate2D, zoom: CGFloat) {
        self.center = center
        self.zoom = zoom
    }
}
