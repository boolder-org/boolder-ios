//
//  DataStore.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/03/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//


import MapKit
import CoreData

class DataStore : ObservableObject {
    var geoStore = GeoStore()
    var topoStore = TopoStore()

    @Published var overlays = [MKOverlay]()
    @Published var annotations = [ProblemAnnotation]()
    @Published var groupedAnnotations = Dictionary<Circuit.CircuitColor, [ProblemAnnotation]>()
    @Published var groupedAnnotationsKeys = [Circuit.CircuitColor]()
    
    // custom wrapper instead of @Published, to be able to refresh data store everytime filters change
    var filters = Filters() {
        willSet { objectWillChange.send() }
        didSet { self.refresh() }
    }

    init() {
        refresh()
    }
    
    func parkingAnnotation() -> PoiAnnotation {
        let parkingAnnotation = PoiAnnotation()
        parkingAnnotation.coordinate = CLLocationCoordinate2D(latitude: 48.462965, longitude: 2.665628)
        parkingAnnotation.title = "Parking"
        parkingAnnotation.subtitle = "2 min de marche"
        
        return parkingAnnotation
    }
    
    func refresh() {
        filterBoulders()
        filterCircuit()
        filterProblems()
        setBelongsToCircuit()
        createGroupedAnnotations()
    }
    
    private func filterProblems() {
        annotations = geoStore.annotations.filter { problem in
            if(filters.circuit == nil || problem.circuitType == filters.circuit) {
                if isGradeOk(problem)  {
                    if filters.steepness.contains(problem.steepness) {
                        if filters.photoPresent == false || problem.isPhotoPresent() {
                            if isHeightOk(problem) {
                                if filters.favorite == false || problem.isFavorite()  {
                                    if filters.ticked == false || problem.isTicked()  {
                                        if filters.risky == true || !problem.isRisky()  {
                                            return true
                                        }
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
        if filters.heightMax == Int.max { return true }
        
        if let height = problem.height {
            return (height <= filters.heightMax)
        }
        else {
            return false
        }
    }
    
    private func isGradeOk(_ problem: ProblemAnnotation) -> Bool {
        if let grade = problem.grade {
            return grade >= filters.gradeMin && grade <= filters.gradeMax
        }
        else {
            return (filters.gradeMin == Filters().gradeMin && filters.gradeMax == Filters().gradeMax)
        }
    }
    
    private func filterBoulders() {
        overlays = geoStore.overlays // FIXME: use boulders instead of overlays
    }
    
    private func filterCircuit() {
        if let circuitType = filters.circuit {
            if let circuit = (geoStore.circuits.first { $0.type == circuitType }) {
                overlays.append(circuit.overlay!)
            }
        }
    }
    
    private func createGroupedAnnotations() {
        var sortedAnnotations = annotations
        sortedAnnotations.sort { (lhs, rhs) -> Bool in
            guard let lhsCircuit = lhs.circuitType else { return true }
            guard let rhsCircuit = rhs.circuitType else { return false }
            
            if lhs.circuitType == rhs.circuitType {
                return lhs.circuitNumberComparableValue() < rhs.circuitNumberComparableValue()
            }
            else {
                return lhsCircuit < rhsCircuit
            }
        }
        
        groupedAnnotations = Dictionary(grouping: sortedAnnotations, by: { (problem: ProblemAnnotation) in
            problem.circuitType ?? Circuit.CircuitColor.offCircuit
        })
        
        groupedAnnotationsKeys = groupedAnnotations.keys.sorted()
    }
    
    private func setBelongsToCircuit() {
        for problem in geoStore.annotations {
            problem.belongsToCircuit = (filters.circuit == problem.circuitType)
        }
    }
    
    func favorites() -> [Favorite] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        request.sortDescriptors = []
        
        do {
            return try context.fetch(request)
        } catch {
            fatalError("Failed to fetch favorites: \(error)")
        }
    }
    
    func ticks() -> [Tick] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request: NSFetchRequest<Tick> = Tick.fetchRequest()
        request.sortDescriptors = []
        
        do {
            return try context.fetch(request)
        } catch {
            fatalError("Failed to fetch ticks: \(error)")
        }
    }
}
