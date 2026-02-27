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
    var presentSearch = false
    var displayCircuitStartButton = false
    private(set) var presentTopoFullScreenRequestCount: Int = 0
    
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
        selectedProblem?.next != nil
    }
    
    func goToNextCircuitProblem() {
        guard let circuit = selectedCircuit else { return }
        if let problem = selectedProblem, !problem.circuitNumber.isEmpty, problem.circuitId == circuit.id {
            if let next = problem.next {
                selectAndPresentAndCenterOnProblem(next)
            }
        } else if let first = circuit.firstProblem {
            selectAndPresentAndCenterOnProblem(first)
        }
    }
    
    var canGoToPreviousCircuitProblem: Bool {
        selectedProblem?.previous != nil
    }
    
    func goToPreviousCircuitProblem() {
        guard let circuit = selectedCircuit else { return }
        if let problem = selectedProblem, !problem.circuitNumber.isEmpty, problem.circuitId == circuit.id {
            if let previous = problem.previous {
                selectAndPresentAndCenterOnProblem(previous)
            }
        } else if let first = circuit.firstProblem {
            selectAndPresentAndCenterOnProblem(first)
        }
    }
    
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
    
    private func centerOnProblem(_ problem: Problem) {
        centerOnProblem = problem
    }
    
    func selectTopo(_ topo: Topo) {
        selection = .topo(topo: topo)
        
        let coordinates = boulderProblems.map { $0.coordinate }
        if !coordinates.isEmpty {
            centerOnBoulder(coordinates: coordinates)
        }
    }
    
    func deselectTopo() {
        guard case .topo(let topo) = selection else { return }
        if let topProblem = topo.topProblem {
            selection = .problem(problem: topProblem)
        } else {
            selection = .none
        }
    }
    
    func centerOnBoulder(coordinates: [CLLocationCoordinate2D]) {
        centerOnBoulderCoordinates = coordinates
        centerOnBoulderCount += 1
    }
    
    func centerOnCurrentLocation() {
        currentLocationCount += 1
    }
    
    func requestTopoFullScreenPresentation() {
        presentTopoFullScreenRequestCount += 1
    }
    
    func clearFilters() {
        filters = Filters()
        filtersRefresh()
    }
    
    private func clearFiltersIfProblemHidden(_ problem: Problem) {
        var hidden = false
        
        if let range = filters.gradeRange {
            if problem.grade < range.min || problem.grade >= range.max {
                hidden = true
            }
        }
        if filters.popular && !problem.featured {
            hidden = true
        }
        if filters.favorite || filters.ticked {
            hidden = true
        }
        
        if hidden {
            clearFilters()
        }
    }
    
    func filtersRefresh() {
        refreshFiltersCount += 1
    }
    
    func updateCameraState(center: CLLocationCoordinate2D, zoom: CGFloat) {
        self.center = center
        self.zoom = zoom
    }
    
    // MARK: - Select a problem or topo
    
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
    
    private var selection: Selection = .none {
        didSet {
            refreshBoulderCacheIfNeeded()
            
            switch selection {
            case .problem(let problem, .circleView):
                clearFiltersIfProblemHidden(problem)
            case .topo:
                clearFilters()
            default:
                break
            }
            
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
    
    var selectedProblem: Problem? {
        switch selection {
        case .problem(let problem, _): return problem
        case .topo(let topo): return cachedTopProblems[topo.id] ?? topo.topProblem
        case .none: return nil
        }
    }
    
    private var selectionSource: Selection.Source {
        if case .problem(_, let source) = selection { return source }
        return .other
    }
    
    var selectedTopo: Topo? {
        if case .topo(let topo) = selection { return topo }
        return nil
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
    @ObservationIgnored private(set) var cachedBoulderId: Int? = nil
    /// Pre-computed top problems per topo – avoids SQLite queries during scroll.
    @ObservationIgnored private var cachedTopProblems: [Int: Problem] = [:]
    /// Pre-computed problems count per topo – avoids SQLite in carousel.
    @ObservationIgnored private var cachedTopoProblemsCount: [Int: Int] = [:]
    
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
            cachedTopoProblemsCount = [:]
            for topo in boulderTopos {
                let problems = topo.problems
                let withLines = problems.filter { $0.line?.coordinates != nil }
                cachedTopProblems[topo.id] = withLines.max { $0.zIndex < $1.zIndex }
                    ?? problems.max { $0.zIndex < $1.zIndex }
                cachedTopoProblemsCount[topo.id] = problems.count
            }
        } else {
            boulderTopos = []
            boulderProblems = []
            cachedTopProblems = [:]
            cachedTopoProblemsCount = [:]
        }
    }
    
    /// Returns the pre-cached top problem for a topo (no database access).
    func topProblem(for topoId: Int) -> Problem? {
        cachedTopProblems[topoId]
    }
    
    /// Returns the pre-cached problems count for a topo (no database access).
    func problemsCount(for topoId: Int) -> Int {
        cachedTopoProblemsCount[topoId] ?? 0
    }
    
    // MARK: - Continuation navigation (scroll without changing selection)
    
    private(set) var navigateToTopoId: Int? = nil
    
    func navigateToContinuation(topoId: Int) {
        navigateToTopoId = topoId
    }
    
    func clearContinuationNavigation() {
        navigateToTopoId = nil
    }
    
    // MARK: - Navigate a boulder's topos
    
    func nextTopo(after topo: Topo) -> Topo? {
        guard let index = boulderTopos.firstIndex(of: topo) else { return nil }
        return boulderTopos[(index + 1) % boulderTopos.count]
    }
    
    func previousTopo(before topo: Topo) -> Topo? {
        guard let index = boulderTopos.firstIndex(of: topo) else { return nil }
        return boulderTopos[(index + boulderTopos.count - 1) % boulderTopos.count]
    }
}
