//
//  AppState.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 10/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import CoreLocation

@Observable
class MapState {
    enum Selection: Equatable {
        case none
        case topo(topo: Topo)
        case problem(problem: Problem, source: Source = .other)
        
        enum Source: Equatable {
            case circleView
            case map
            case other
        }
    }
    
    var selection: Selection = .none {
        didSet {
            refreshBoulderCacheIfNeeded()
            
            // Update narrow derived properties – they only publish a change
            // when the *mode* flips, not on every topo-to-topo swap.
            let newMode = { if case .topo = selection { return true } else { return false } }()
            if isInTopoMode != newMode { isInTopoMode = newMode }
            
            let newSource: Selection.Source = {
                if case .problem(_, let s) = selection { return s } else { return .other }
            }()
            if currentSelectionSource != newSource { currentSelectionSource = newSource }
            
            let newProblemId: Int = {
                if case .problem(let p, _) = selection { return p.id } else { return 0 }
            }()
            if activeProblemId != newProblemId { activeProblemId = newProblemId }
        }
    }
    
    // MARK: - Narrow observation tokens (stable during topo-to-topo swipes)
    
    /// `true` when selection is `.topo(…)`. Views that only care about the
    /// mode (not *which* topo) should read this instead of `selection` to
    /// avoid unnecessary body re-evaluations.
    private(set) var isInTopoMode: Bool = false
    
    /// Mirrors `Selection.Source` but only changes when the source actually
    /// differs, keeping views stable during topo-to-topo swipes.
    private(set) var currentSelectionSource: Selection.Source = .other
    
    /// The id of the actively selected problem (0 when in topo mode or none).
    /// Stable during topo-to-topo swipes; only changes on problem-to-problem taps.
    private(set) var activeProblemId: Int = 0
    
    // MARK: - Cached boulder data (only refreshed when boulder changes)
    
    private(set) var boulderTopos: [Topo] = []
    private(set) var boulderProblems: [Problem] = []
    @ObservationIgnored private var cachedBoulderId: Int? = nil
    /// Pre-computed top problems per topo – avoids SQLite queries during scroll.
    @ObservationIgnored private var cachedTopProblems: [Int: Problem] = [:]
    /// Pre-computed allProblems count per topo – avoids SQLite in carousel.
    @ObservationIgnored private var cachedTopoAllProblemsCount: [Int: Int] = [:]
    
    private func refreshBoulderCacheIfNeeded() {
        let boulderId: Int?
        switch selection {
        case .topo(let topo): boulderId = topo.boulderId
        case .problem(let problem, _): boulderId = problem.topo?.boulderId
        case .none: boulderId = nil
        }
        
        guard boulderId != cachedBoulderId else { return }
        cachedBoulderId = boulderId
        
        if let boulderId {
            let boulder = Boulder(id: boulderId)
            boulderTopos = boulder.topos
            boulderProblems = boulder.problems
            // Pre-cache per-topo data so page views never hit SQLite during scroll
            cachedTopProblems = [:]
            cachedTopoAllProblemsCount = [:]
            for topo in boulderTopos {
                let allProblems = topo.allProblems
                let withLines = allProblems.filter { $0.line?.coordinates != nil }
                cachedTopProblems[topo.id] = withLines.max { $0.zIndex < $1.zIndex }
                    ?? allProblems.max { $0.zIndex < $1.zIndex }
                cachedTopoAllProblemsCount[topo.id] = allProblems.count
            }
        } else {
            boulderTopos = []
            boulderProblems = []
            cachedTopProblems = [:]
            cachedTopoAllProblemsCount = [:]
        }
    }
    
    /// Returns the pre-cached top problem for a topo (no database access).
    func topProblem(for topoId: Int) -> Problem? {
        cachedTopProblems[topoId]
    }
    
    /// Returns the pre-cached allProblems count for a topo (no database access).
    func allProblemsCount(for topoId: Int) -> Int {
        cachedTopoAllProblemsCount[topoId] ?? 0
    }
    
    func nextTopo(after topo: Topo) -> Topo? {
        guard let index = boulderTopos.firstIndex(of: topo) else { return nil }
        return boulderTopos[(index + 1) % boulderTopos.count]
    }
    
    func previousTopo(before topo: Topo) -> Topo? {
        guard let index = boulderTopos.firstIndex(of: topo) else { return nil }
        return boulderTopos[(index + boulderTopos.count - 1) % boulderTopos.count]
    }
    
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
    
    var selectedProblem: Problem {
        get {
            switch selection {
            case .problem(let problem, _): return problem
            case .topo(let topo): return cachedTopProblems[topo.id] ?? topo.topProblem ?? Problem.empty
            case .none: return Problem.empty
            }
        }
        set {
            selection = .problem(problem: newValue)
        }
    }
    
    var selectionSource: Selection.Source {
        if case .problem(_, let source) = selection { return source }
        return .other
    }
    
    var selectedTopo: Topo? {
        if case .topo(let topo) = selection { return topo }
        return nil
    }
    
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
    func selectProblem(_ problem: Problem, source: Selection.Source = .other) {
        selection = .problem(problem: problem, source: source)
        
        selectedArea = Area.load(id: problem.areaId)
    }
    
    func selectAndPresentAndCenterOnProblem (_ problem: Problem) {
        centerOnProblem(problem)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            self.selectProblem(problem)
            self.presentProblemDetails = true
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
