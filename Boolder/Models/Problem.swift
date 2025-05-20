//
//  Problem.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 09/05/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import SQLite

struct Problem : Identifiable {
    static let defaultCircuitNumber = "D"
    let id: Int
    let name: String?
    let nameEn: String?
    let nameSearchable: String?
    let grade: Grade
    let coordinate: CLLocationCoordinate2D
    let steepness: Steepness
    let sitStart: Bool
    let areaId: Int
    let circuitId: Int?
    let circuitColor: Circuit.CircuitColor?
    let circuitNumber: String
    let bleauInfoId: String?
    let featured: Bool
    let popularity: Int?
    let parentId: Int?
    let startId: Int?
    let endId: Int?
    
    // TODO: remove
    static let empty = Problem(id: 0, name: "", nameEn: "", nameSearchable: "", grade: Grade.min, coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), steepness: .other, sitStart: false, areaId: 0, circuitId: nil, circuitColor: .offCircuit, circuitNumber: "", bleauInfoId: nil, featured: false, popularity: 0, parentId: nil, startId: nil, endId: nil)
    
    var circuitUIColor: UIColor {
        circuitColor?.uicolor ?? UIColor.gray
    }
    
    var circuitUIColorForPhotoOverlay: UIColor {
        circuitColor?.uicolorForPhotoOverlay ?? UIColor.gray
    }
    
    var localizedName: String {
        if NSLocale.websiteLocale == "fr" {
            return name ?? ""
        }
        else {
            return nameEn ?? ""
        }
    }
    
    var circuitNumberComparableValue: Double {
        if let int = Int(circuitNumber) {
            return Double(int)
        }
        else {
            if let int = Int(circuitNumber.dropLast()) {
                return 0.5 + Double(int)
            }
            else {
                return 0
            }
        }
    }
    
    var topoId: Int? {
        line?.topoId
    }
    
    var topo: Topo? {
        guard let topoId = topoId else { return nil }
        
        return Topo.load(id: topoId)
    }
    
    var onDiskPhoto: UIImage? {
        topo?.onDiskPhoto
    }
    
    var variants: [Problem] {
        if let parent = parent {
            return parent.variants
        }
        else {
            return [self] + children
        }
    }
    
    var zIndex: Double {
        let bonusCircuit = circuitId != nil ? 1000.0 : 0.0
        let tiebreaker = Double(id) / 100
        return Double(popularity ?? 0) + bonusCircuit + tiebreaker
    }
    
    var readableColor: UIColor {
        if circuitColor == Circuit.CircuitColor.white {
            return UIColor.black
        }
        else {
            return UIColor.black
        }
    }
    
    func distance(to other: Line.PhotoPercentCoordinate) -> Double {
        if let point = lineFirstPoint {
            return point.distance(to: other)
        }
        else {
            return 1
        }
    }

    // TODO: remove
    var lineFirstPoint: Line.PhotoPercentCoordinate? {
        guard let line = line else { return nil }
        
        return line.firstPoint
    }
    
    // TODO: remove
    var lineLastPoint: Line.PhotoPercentCoordinate? {
        guard let line = line else { return nil }
        
        return line.lastPoint
    }
    
    var isFavorite: Bool {
        favorite != nil
    }
    
    var favorite: Favorite? {
        favorites.first { (favorite: Favorite) -> Bool in
            return Int(favorite.problemId) == id
        }
    }
    
    var isTicked: Bool {
        tick != nil
    }
    
    var tick: Tick? {
        ticks.first { (tick: Tick) -> Bool in
            return Int(tick.problemId) == id
        }
    }
}

// MARK: SQLite
extension Problem {
    static let id = Expression<Int>("id")
    static let areaId = Expression<Int>("area_id")
    static let name = Expression<String?>("name")
    static let nameEn = Expression<String?>("name_en")
    static let nameSearchable = Expression<String?>("name_searchable")
    static let grade = Expression<String>("grade")
    static let steepness = Expression<String>("steepness")
    static let circuitNumber = Expression<String?>("circuit_number")
    static let circuitColor = Expression<String?>("circuit_color")
    static let circuitId = Expression<Int?>("circuit_id")
    static let bleauInfoId = Expression<String?>("bleau_info_id")
    static let parentId = Expression<Int?>("parent_id")
    static let startId = Expression<Int?>("start_id")
    static let endId = Expression<Int?>("end_id")
    static let latitude = Expression<Double>("latitude")
    static let longitude = Expression<Double>("longitude")
    static let sitStart = Expression<Int>("sit_start")
    static let featured = Expression<Int>("featured")
    static let popularity = Expression<Int?>("popularity")
    
    static func load(id: Int) -> Problem? {
        do {
            let problems = Table("problems").filter(self.id == id)
            
            if let p = try SqliteStore.shared.db.pluck(problems) {
                return Problem(
                    id: id,
                    name: p[name],
                    nameEn: p[nameEn],
                    nameSearchable: p[nameSearchable],
                    grade: Grade(p[grade]),
                    coordinate: CLLocationCoordinate2D(latitude: p[latitude], longitude: p[longitude]),
                    steepness: Steepness(rawValue: p[steepness]) ?? .other,
                    sitStart: p[sitStart] == 1,
                    areaId: p[areaId],
                    circuitId: p[circuitId],
                    circuitColor: Circuit.CircuitColor.colorFromString(p[circuitColor]),
                    circuitNumber: p[circuitNumber] ?? "",
                    bleauInfoId: p[bleauInfoId],
                    featured: p[featured] == 1,
                    popularity: p[popularity],
                    parentId: p[parentId],
                    startId: p[startId],
                    endId: p[endId]
                )
            }
            
            return nil
        }
        catch {
            print (error)
            return nil
        }
    }
    
    static func search(_ text: String) -> [Problem] {
        let query = Table("problems")
            .order(popularity.desc)
            .filter(nameSearchable.like("%\(text.normalized)%"))
            .limit(20)
        
        do {
            return try SqliteStore.shared.db.prepare(query).map { p in
                Problem.load(id: p[id])
            }.compactMap{$0}
        }
        catch {
            print (error)
            return []
        }
    }
    
    var showLine: Bool {
//        let hidden = [7702, 7703, 15692, 15699]
//        
//        if hidden.contains(id) {
//            return false
//        }
        
        return true
    }
    
    // TODO: handle multiple lines
    var line: Line? {
        let lines = Table("lines")
            .filter(Line.problemId == id)
        
        do {
            if let l = try SqliteStore.shared.db.pluck(lines) {
                return Line.load(id: l[Line.id])
            }
            
            return nil
        }
        catch {
            print (error)
            return nil
        }
    }
    
    var overlayBadgePosition: Line.PhotoPercentCoordinate? {
        guard let line = line else { return nil }
        
        if id == 3875 { // samarkand
            return line.overlayPoint(at: 0.7)
        }
        else if id == 3876 { // samarkand rallongé
            return line.overlayPoint(at: 0.4)
        }
        else if id == 3877 { // samarkand rallongé pas le bas
            return line.overlayPoint(at: 0.5)
        }
        else if id == 3878 { // les inversées
            return line.overlayPoint(at: 0.45)
        }
        else if id == 3873 { // sabots neufs
            return line.overlayPoint(at: 0.5)
        }
        
        
        else if id == 4092 { // surplom de la mée
            return line.overlayPoint(at: 0.5)
        }
        else if id == 4095 { // putain du diable
            return line.overlayPoint(at: 0.7)
        }
        else if id == 4096 { // putain du diable assis
            return line.overlayPoint(at: 0.55)
        }
        
        
        else if id == 230 { // levitation
            return line.overlayPoint(at: 0.5)
        }
        else if id == 7702 { // vagabond des limbes
            return line.overlayPoint(at: 0.8)
        }
        else if id == 7703 { // vagabond des limbes prolongé
            return line.overlayPoint(at: 0.7)
        }
        else if id == 15699 { // rocking chair du fond
            return line.overlayPoint(at: 0.15)
        }
        else if id == 15692 { // levitation du fond
            return line.overlayPoint(at: 0.2)
        }
        else if id == 7675 { // levitation raccourci
            return line.overlayPoint(at: 0.35)
        }
        else if id == 7676 { // rocking chair
            return line.overlayPoint(at: 0.5)
        }
        
        
        if parentId != nil && sitStart {
            return line.overlayPoint(at: 0.25)
        }
        else {
            return line.overlayPoint(at: 0.4)
        }
    }
    
    var topPosition: Line.PhotoPercentCoordinate? {
        guard let line = line else { return nil }
        
        return line.lastPoint
    }
    
    // TODO: move to Topo ?
    var otherProblemsOnSameTopo: [Problem] {
        guard let topo = topo else { return [] }
        
        return topo.otherProblemsOnSameTopo
    }
    
    var otherProblemsOnSameBoulder: [Problem] {
        guard let topo = topo, let boulderId = topo.boulderId else { return [] }
        
        return Topo.onBoulder(boulderId).flatMap{$0.otherProblemsOnSameTopo}
    }
    
    var toposOnSameBoulder: [Topo] {
        topo?.onSameBoulder ?? []
    }

    
    // TODO: move to Topo
    var startGroups: [StartGroup] {
        guard let topo = topo else { return [] }
        
        return topo.startGroups
    }
    
    var startGroup : StartGroup? {
        startGroups.first { $0.problems.contains(self) }
    }
    
    var indexWithinStartGroup: Int? {
        startGroup?.problemsToDisplay.firstIndex(of: self)
    }
    
    var start: Problem {
        if let startId = startId {
            return Self.load(id: startId) ?? self
        }
        
        return self
    }

    var children: [Problem] {
        let problems = Table("problems")
            .filter(Problem.parentId == id)

        do {
            return try SqliteStore.shared.db.prepare(problems).map { problem in
                Self.load(id: problem[Problem.id])
            }.compactMap{$0}
        }
        catch {
            print (error)
            return []
        }
    }
    
    var parent: Problem? {
        guard let parentId = parentId else { return nil }
        
        return Self.load(id: parentId)
    }
    
    var next: Problem? {
        let circutiNumberInt = (self.circuitNumber == Problem.defaultCircuitNumber) ? 0 : Int(self.circuitNumber)
        if let circuitNumberInt = circutiNumberInt, let circuitId = circuitId {
            let nextNumber = String(circuitNumberInt + 1)
            
            let query = Table("problems")
                .filter(Problem.circuitId == circuitId)
                .filter(Problem.circuitNumber == nextNumber)
            
            if let p = try! SqliteStore.shared.db.pluck(query) {
                return Problem.load(id: p[Problem.id])
            }
        }
        
        return nil
    }
    
    var previous: Problem? {
        if let circuitNumberInt = Int(self.circuitNumber), let circuitId = circuitId {
            let previousNumber = (circuitNumberInt == 1 ) ? Problem.defaultCircuitNumber : String(circuitNumberInt - 1)
            let query = Table("problems")
                .filter(Problem.circuitId == circuitId)
                .filter(Problem.circuitNumber == previousNumber)
            
            if let p = try! SqliteStore.shared.db.pluck(query) {
                return Problem.load(id: p[Problem.id])
            }
        }
        
        return nil
    }
}

// MARK: CoreData
extension Problem {
    var favorites: [Favorite] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        request.sortDescriptors = []
        
        do {
            return try context.fetch(request)
        } catch {
            fatalError("Failed to fetch favorites: \(error)")
        }
    }
    
    var ticks: [Tick] {
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

extension Problem: CustomStringConvertible {
    var description: String {
        return "Problem \(id)"
    }
}

extension Problem : Hashable {
    static func == (lhs: Problem, rhs: Problem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// TODO: move to Topo
struct StartGroup: Identifiable, Equatable {
    var id: Int {
        startId ?? 0
    }
    
//    private(set) var problems: [Problem]
    let startId: Int?
    let problems: [Problem]
    
    var sortedProblems: [Problem] {
        problems.sorted { $0.grade < $1.grade } //.sorted { ($0.lineLastPoint?.x ?? 1) < ($1.lineLastPoint?.y ?? 1) }
    }
    
    var problemsToDisplay: [Problem] {
        sortedProblems //.filter { $0.parentId == nil }
    }
    
    var problemsToBeConsidered: [Problem] {
        sortedProblems.filter { $0.parentId == nil }
    }
    
    func next(after: Problem) -> Problem? {
        if let index = problemsToDisplay.firstIndex(of: after) {
            return problemsToDisplay[(index + 1) % problemsToDisplay.count]
        }
        
        return nil
    }
    
    var topProblem: Problem? {
        sortedProblems.first
    }
}
