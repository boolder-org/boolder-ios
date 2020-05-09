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
    @Published var problems = [Problem]()
    @Published var groupedProblems = Dictionary<Circuit.CircuitColor, [Problem]>()
    @Published var groupedProblemsKeys = [Circuit.CircuitColor]()
    
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
        overlays = geoStore.boulderOverlays
        if let circuitOverlay = circuitOverlay() {
            overlays.append(circuitOverlay)
        }
        
        problems = filteredProblems()
        setBelongsToCircuit()
        createGroupedAnnotations()
    }
    
    private func filteredProblems() -> [Problem] {
        return geoStore.problems.filter { problem in
            if(filters.circuit == nil || problem.circuitColor == filters.circuit) {
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
    
    private func isHeightOk(_ problem: Problem) -> Bool {
        if filters.heightMax == Int.max { return true }
        
        if let height = problem.height {
            return (height <= filters.heightMax)
        }
        else {
            return false
        }
    }
    
    private func isGradeOk(_ problem: Problem) -> Bool {
        if let grade = problem.grade {
            return grade >= filters.gradeMin && grade <= filters.gradeMax
        }
        else {
            return (filters.gradeMin == Filters().gradeMin && filters.gradeMax == Filters().gradeMax)
        }
    }
    
    private func circuitOverlay() -> CircuitOverlay? {
        if let circuitColor = filters.circuit {
            if let circuit = circuit(withColor: circuitColor) {
                return circuit.overlay
            }
        }
        
        return nil
    }
    
    func circuit(withColor color: Circuit.CircuitColor) -> Circuit? {
        geoStore.circuits.first { $0.color == color }
    }
    
    private func createGroupedAnnotations() {
        var sortedProblems = problems
        sortedProblems.sort { (lhs, rhs) -> Bool in
            guard let lhsCircuit = lhs.circuitColor else { return true }
            guard let rhsCircuit = rhs.circuitColor else { return false }
            
            if lhs.circuitColor == rhs.circuitColor {
                return lhs.circuitNumberComparableValue() < rhs.circuitNumberComparableValue()
            }
            else {
                return lhsCircuit < rhsCircuit
            }
        }
        
        groupedProblems = Dictionary(grouping: sortedProblems, by: { (problem: Problem) in
            problem.circuitColor ?? Circuit.CircuitColor.offCircuit
        })
        
        groupedProblemsKeys = groupedProblems.keys.sorted()
    }
    
    private func setBelongsToCircuit() {
        for problem in problems {
            problem.belongsToCircuit = (filters.circuit == problem.circuitColor)
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
