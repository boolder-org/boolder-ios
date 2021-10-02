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
    var geoStore = GeoStore(areaId: 1)
    var topoStore = TopoStore(areaId: 1)
    
    var areaId: Int = 1 {
        didSet {
            if oldValue != areaId {
                self.geoStore = GeoStore(areaId: areaId)
                self.topoStore = TopoStore(areaId: areaId)
                self.refresh()
            }
        }
    }
    
    // custom wrapper instead of @Published, to be able to refresh data store everytime filters change
    var filters = Filters() {
        willSet { objectWillChange.send() }
        didSet { self.refresh() }
    }

    @Published var overlays = [MKOverlay]()
    @Published var problems = [Problem]()
    @Published var pois = [Poi]()
    @Published var groupedProblems = Dictionary<Circuit.CircuitColor, [Problem]>()
    @Published var groupedProblemsKeys = [Circuit.CircuitColor]()
    
    let areas = [
        Area(id: 1,  name: "Rocher Canon",          problemsCount: 389, published: true),
        Area(id: 2,  name: "Cul de Chien",          problemsCount: 244, published: true),
        Area(id: 4,  name: "Cuvier",                problemsCount: 502, published: true),
        Area(id: 5,  name: "Franchard Isatis",      problemsCount: 571, published: true),
        Area(id: 6,  name: "Cuvier Bellevue",       problemsCount: 107, published: true),
        Area(id: 7,  name: "Apremont",              problemsCount: 385, published: true),
        Area(id: 8,  name: "Rocher Fin",            problemsCount: 1,   published: false),
        Area(id: 9,  name: "Éléphant",              problemsCount: 256, published: true),
        Area(id: 10, name: "95.2",                  problemsCount: 327, published: true),
        Area(id: 11, name: "Franchard Cuisinière",  problemsCount: 443, published: true),
        Area(id: 12, name: "Roche aux Sabots",      problemsCount: 230, published: true),
        Area(id: 13, name: "Canche aux Merciers",   problemsCount: 330, published: true),
        Area(id: 14, name: "Rocher du Potala",      problemsCount: 317, published: true),
        Area(id: 15, name: "Gorge aux Châts",       problemsCount: 207, published: true),
        Area(id: 16, name: "91.1",                  problemsCount: 260, published: false),
        Area(id: 17, name: "Rocher Guichot",        problemsCount: 123, published: true),
        Area(id: 18, name: "Diplodocus",            problemsCount: 107, published: true),
    ]

    init() {
        refresh()
    }
    
    func area(withId id: Int) -> Area? {
        areas.first(where:  { area in
            area.id == id
        })
    }
    
    func refresh() {
        overlays = geoStore.boulderOverlays
        
        if let circuitOverlay = circuitOverlay() {
            overlays.append(circuitOverlay)
        }
        
        overlays.append(contentsOf: geoStore.poiRouteOverlays)
        
        problems = filteredProblems()
        setBelongsToCircuit()
        createGroupedProblems()
        
        pois = geoStore.pois
    }
    
    private func filteredProblems() -> [Problem] {
        return geoStore.problems.filter { problem in
            if(filters.circuitId == nil || problem.circuitId == filters.circuitId) {
                if isGradeOk(problem)  {
                    if isSteepnessOk(problem) {
                        if filters.photoPresent == false || (problem.mainTopoPhoto != nil) {
                            if isHeightOk(problem) {
                                if filters.favorite == false || problem.isFavorite()  {
                                    if filters.ticked == false || problem.isTicked()  {
                                        if filters.risky == true || !problem.isRisky()  {
                                            if isMapMakerModeOk(problem) {
                                                return true
                                            }
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
    
    private func isMapMakerModeOk(_ problem: Problem) -> Bool {
        filters.mapMakerModeEnabled == false || !problem.isFavorite()
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
        if let range = filters.gradeRange {
            return range.grades.contains(problem.grade)
        }
        else {
            return true
        }
    }
    
    private func isSteepnessOk(_ problem: Problem) -> Bool {
        if filters.steepness.isEmpty {
            return true
        }
        
        return filters.steepness.contains(problem.steepness)
    }
    
    private func circuitOverlay() -> CircuitOverlay? {
        if let circuitId = filters.circuitId {
            if let circuit = circuit(withId: circuitId) {
                return circuit.overlay
            }
        }
        
        return nil
    }
    
    func circuit(withId id: Int) -> Circuit? {
        geoStore.circuits.first { $0.id == id }
    }
    
    private func createGroupedProblems() {
        var sortedProblems = problems
        sortedProblems.sort { (lhs, rhs) -> Bool in
            if lhs.circuitNumber == rhs.circuitNumber {
                return lhs.grade < rhs.grade
            }
            else {
                return lhs.circuitNumberComparableValue() < rhs.circuitNumberComparableValue()
            }
        }
        
        groupedProblems = Dictionary(grouping: sortedProblems, by: { (problem: Problem) in
            problem.circuitColor ?? Circuit.CircuitColor.offCircuit
        })
        
        groupedProblemsKeys = groupedProblems.keys.sorted()
    }
    
    func orderedProblems() -> [Problem] {
        var result: [Problem] = []
        
        for key in groupedProblemsKeys {
            result.append(contentsOf: groupedProblems[key]!)
        }
        
        return result
    }
    
    private func setBelongsToCircuit() {
        for problem in problems {
            problem.belongsToCircuit = (filters.circuitId != nil && filters.circuitId == problem.circuitId)
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
