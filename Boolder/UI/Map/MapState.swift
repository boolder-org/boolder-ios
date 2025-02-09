//
//  AppState.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 10/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import CoreLocation

class MapState : ObservableObject {
    @Published var selectedProblem: Problem? = nil
    @Published private(set) var centerOnProblem: Problem? = nil
    @Published private(set) var selectedArea: Area? = nil
    @Published private(set) var currentLocation: Bool = false
    @Published private(set) var center: CLLocationCoordinate2D? = nil
    @Published private(set) var zoom: CGFloat? = nil
    @Published private(set) var centerOnArea: Area? = nil
    @Published private(set) var selectedCluster: Cluster? = nil
    @Published private(set) var selectedCircuit: Circuit? = nil
    @Published private(set) var centerOnCircuit: Circuit? = nil
    @Published var selectedPoi: Poi? = nil
    @Published var filters: Filters = Filters()
    @Published private(set) var refreshFilters: Bool = false
    
    @Published var presentProblemDetails = false
    @Published var presentPoiActionSheet = false
    @Published var presentFilters = false
    @Published var presentAreaView = false
    @Published var presentCircuitPicker = false
    @Published var displayCircuitStartButton = false
    
    func centerOnArea(_ area: Area) {
        centerOnArea = area
    }
    
    func selectArea(_ area: Area) {
        selectedArea = area
        
        if let clusterId = area.clusterId, let cluster = Cluster.load(id: clusterId) {
            selectCluster(cluster)
        }
    }
    
    func selectCluster(_ cluster: Cluster) {
        selectedCluster = cluster
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
        selectedProblem?.next != nil
    }
    
    func goToNextCircuitProblem() {
        if let circuit = selectedCircuit {
            if !(selectedProblem?.circuitNumber.isEmpty == true) && selectedProblem?.circuitId == circuit.id {
                if let next = selectedProblem?.next {
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
        selectedProblem?.previous != nil
    }
    
    func goToPreviousCircuitProblem() {
        if let circuit = selectedCircuit {
            if !(selectedProblem?.circuitNumber.isEmpty == true) && selectedProblem?.circuitId == circuit.id {
                if let previous = selectedProblem?.previous {
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
    func selectProblem(_ problem: Problem) {
        selectedProblem = problem
        
        selectedArea = Area.load(id: problem.areaId)
    }
    
    func selectAndPresentAndCenterOnProblem (_ problem: Problem) {
        centerOnProblem(problem)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            self.selectProblem(problem)
            self.presentProblemDetails = true
        }
    }
    
    func centerOnCurrentLocation() {
        currentLocation = true
    }
    
    func clearFilters() {
        filters = Filters()
        filtersRefresh()
    }
    
    func filtersRefresh() {
        refreshFilters = true
    }
    
    func updateCameraState(center: CLLocationCoordinate2D, zoom: CGFloat) {
        self.center = center
        self.zoom = zoom
    }
}
