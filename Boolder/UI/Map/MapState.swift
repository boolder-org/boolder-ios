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
    
    // MARK: Topo problem navigation (prev/next on boulder)
    
    func goToNextTopoProblem() {
        if showAllLines {
            goToNextTopo()
        } else if let next = nextTopoProblem {
            selectProblem(next)
        }
    }
    
    func goToPreviousTopoProblem() {
        if showAllLines {
            goToPreviousTopo()
        } else if let prev = previousTopoProblem {
            selectProblem(prev)
        }
    }
    
    private func goToNextTopo() {
        guard let topo = selectedProblem.topo, let boulderId = topo.boulderId,
              let next = Boulder(id: boulderId).nextTopo(after: topo) else { return }
        if let topProblem = next.topProblem {
            selectProblem(topProblem)
        }
    }
    
    private func goToPreviousTopo() {
        guard let topo = selectedProblem.topo, let boulderId = topo.boulderId,
              let previous = Boulder(id: boulderId).previousTopo(before: topo) else { return }
        if let topProblem = previous.topProblem {
            selectProblem(topProblem)
        }
    }
    
    private var nextTopoProblem: Problem? {
        guard let topo = selectedProblem.topo else { return nil }
        
        let sorted = topo.problems.sorted { $0.xIndex < $1.xIndex }
        
        if let index = sorted.firstIndex(of: selectedProblem) {
            let nextIndex = index + 1
            if nextIndex < sorted.count {
                return sorted[nextIndex]
            }
        }
        
        // Wrap to next topo on the same boulder
        let toposOnBoulder = topo.onSameBoulder
        guard toposOnBoulder.count > 1 else {
            // Only one topo: wrap within it
            let sorted = topo.problems.sorted { $0.xIndex < $1.xIndex }
            return sorted.first
        }
        
        if let topoIndex = toposOnBoulder.firstIndex(of: topo) {
            let nextTopoIndex = (topoIndex + 1) % toposOnBoulder.count
            let nextTopo = toposOnBoulder[nextTopoIndex]
            let nextSorted = nextTopo.problems.sorted { $0.xIndex < $1.xIndex }
            return nextSorted.first
        }
        
        return nil
    }
    
    private var previousTopoProblem: Problem? {
        guard let topo = selectedProblem.topo else { return nil }
        
        let sorted = topo.problems.sorted { $0.xIndex < $1.xIndex }
        
        if let index = sorted.firstIndex(of: selectedProblem) {
            let prevIndex = index - 1
            if prevIndex >= 0 {
                return sorted[prevIndex]
            }
        }
        
        // Wrap to previous topo on the same boulder
        let toposOnBoulder = topo.onSameBoulder
        guard toposOnBoulder.count > 1 else {
            // Only one topo: wrap within it
            let sorted = topo.problems.sorted { $0.xIndex < $1.xIndex }
            return sorted.last
        }
        
        if let topoIndex = toposOnBoulder.firstIndex(of: topo) {
            let prevTopoIndex = (topoIndex - 1 + toposOnBoulder.count) % toposOnBoulder.count
            let prevTopo = toposOnBoulder[prevTopoIndex]
            let prevSorted = prevTopo.problems.sorted { $0.xIndex < $1.xIndex }
            return prevSorted.last
        }
        
        return nil
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
