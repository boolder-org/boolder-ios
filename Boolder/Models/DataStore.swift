//
//  DataStore.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/03/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//


import MapKit

class DataStore : ObservableObject {
    
    static let shared = DataStore()
    
    var geoStore = GeoStore()

    @Published var overlays = [MKOverlay]()
    @Published var annotations = [ProblemAnnotation]()
    @Published var groupedAnnotations = Dictionary<Int, [ProblemAnnotation]>()
    @Published var topoCollection = GeoStore.TopoCollection.init(topos: nil)
    
    // custom wrapper instead of @Published, to be able to refresh data store everytime filters change
    var filters = Filters() {
        willSet { objectWillChange.send() }
        didSet { self.refresh() }
    }

    init() {
        refresh()
    }
    
    func refresh() {
        filterCircuits()
        filterProblems()
        setBelongsToCircuit()
        createGroupedAnnotations()
    }
    
    private func filterProblems() {
        annotations = geoStore.annotations.filter { problem in
            if(filters.circuit == nil || problem.circuitType == filters.circuit) {
                if let gradeCategory = problem.grade?.category() {
                    if filters.gradeCategories.isEmpty || filters.gradeCategories.contains(gradeCategory) {
                        if filters.steepness.contains(problem.steepness) {
                            if filters.photoPresent == false || problem.isPhotoPresent() {
                                if isHeightOk(problem) {
                                    if filters.favorite == false || problem.isFavorite()  {
                                        return true
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return false
        }
    }
    
    private func isHeightOk(_ problem: ProblemAnnotation) -> Bool {
        if filters.heightMax == 6 { return true }
        
        if let height = problem.height {
            return (height <= filters.heightMax)
        }
        else {
            return false
        }
    }
    
    private func filterCircuits() {
        overlays = geoStore.overlays.filter { overlay in
            if let circuit = overlay as? CircuitOverlay {
                return circuit.circuitType == filters.circuit
            }
            
            return true
        }
    }
    
    private func createGroupedAnnotations() {
        var sortedAnnotations = annotations
        sortedAnnotations.sort { (lhs, rhs) -> Bool in
            guard let lhsGrade = lhs.grade else { return true }
            guard let rhsGrade = rhs.grade else { return false }
            
            return lhsGrade < rhsGrade
        }
        groupedAnnotations = Dictionary(grouping: sortedAnnotations, by: { (problem: ProblemAnnotation) in problem.grade?.category() ?? 0 })
    }
    
    private func setBelongsToCircuit() {
        for problem in geoStore.annotations {
            problem.belongsToCircuit = (filters.circuit == problem.circuitType)
        }
    }
}
