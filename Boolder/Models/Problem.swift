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
    
    // TODO: remove
    static let empty = Problem(id: 0, name: "", nameEn: "", nameSearchable: "", grade: Grade.min, coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), steepness: .other, sitStart: false, areaId: 0, circuitId: nil, circuitColor: .offCircuit, circuitNumber: "", bleauInfoId: nil, featured: false, popularity: 0, parentId: nil)
    
    var zIndex: Double {
        if let popularity = popularity {
            Double(popularity)
        }
        else {
            Double(id) / 100000
        }
    }
    
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
    
    func circuitNumberComparableValue() -> Double {
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
    
    // Same logic exists server side: https://github.com/nmondollot/boolder/blob/145d1b7fbebfc71bab6864e081d25082bcbeb25c/app/models/problem.rb#L99-L105
    var variants: [Problem] {
        if let parent = parent {
            return parent.variants
        }
        else {
            return [self] + children
        }
    }

    // TODO: rename and move to Line
    func lineFirstPoint() -> Line.PhotoPercentCoordinate? {
        guard let line = line else { return nil }
        guard let coordinates = line.coordinates else { return nil }
        guard let firstPoint = coordinates.first else { return nil }
        
        return firstPoint
    }
    
    var topoId: Int? {
        line?.topoId
    }
    
    var topo: Topo? {
        guard let topoId = topoId else { return nil }
        
        return Topo(id: topoId, areaId: areaId)
    }
    
    var onDiskPhoto: UIImage? {
        topo?.onDiskPhoto
    }
    
    func isFavorite() -> Bool {
        favorite() != nil
    }
    
    func favorite() -> Favorite? {
        favorites().first { (favorite: Favorite) -> Bool in
            return Int(favorite.problemId) == id
        }
    }
    
    func isTicked() -> Bool {
        tick() != nil
    }
    
    func tick() -> Tick? {
        ticks().first { (tick: Tick) -> Bool in
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
                    parentId: p[parentId]
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
    
    var otherProblemsOnSameTopo: [Problem] {
        guard let l = line else { return [] }
        
        let lines = Table("lines")
            .filter(Line.topoId == l.topoId)

        do {
            let problemsOnSameTopo = try SqliteStore.shared.db.prepare(lines).map { l in
                Self.load(id: l[Line.problemId])
            }
            
            // TODO: clean up once we handle ordering of multiple lines
            return problemsOnSameTopo.compactMap{$0}
                .filter { $0.topoId == self.topoId }
                .filter{ $0.line?.coordinates != nil }
        }
        catch {
            print (error)
            return []
        }
    }
    
    // TODO: move to Topo
    var startGroups: [StartGroup] {
        var groups = [StartGroup]()
        
        otherProblemsOnSameTopo.forEach { p in
            let group = groups.first{$0.overlaps(with: p)}
            
            if let group = group {
                group.addProblem(p)
            }
            else {
                groups.append(StartGroup(problem: p))
            }
        }
        
        return groups
    }
    
    func distance(from: Problem) -> Double {
        if let a = from.lineFirstPoint(), let b = self.lineFirstPoint() {
            let dx = a.x - b.x
            let dy = a.y - b.y
            return sqrt(dx*dx + dy*dy)
        }
        else {
            return 1.0
        }
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
        if let circuitNumberInt = Int(self.circuitNumber), let circuitId = circuitId {
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
            let previousNumber = String(circuitNumberInt - 1)
            
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


class StartGroup: Identifiable, Comparable {
    private(set) var problems: [Problem]

    init(problem: Problem) {
        self.problems = [problem]
    }

    func overlaps(with problem: Problem) -> Bool {
        return problems.contains { p in
            p.distance(from: problem) < 0.03
        }
    }
    
//    func reactsToTap(at: Line.PhotoPercentCoordinate) -> Bool {
//        return problems.contains { p in
//            if let b = p.lineFirstPoint() {
//                return distance(a: at, b: b) < 0.05
//            }
//            else {
//                return false
//            }
//        }
//    }
    
    func distance(at: Line.PhotoPercentCoordinate) -> Double {
        return problems.map { p in
            if let b = p.lineFirstPoint() {
                return distance(a: at, b: b)
            }
            else {
                return 1.0
            }
        }.min() ?? 1.0
    }
    
    static func == (lhs: StartGroup, rhs: StartGroup) -> Bool {
        lhs.problems.map{$0.id} == rhs.problems.map{$0.id}
    }
    
    static func < (lhs: StartGroup, rhs: StartGroup) -> Bool {
        lhs.popularity < rhs.popularity
    }
    
    var popularity : Int {
        problems.map{$0.popularity}.compactMap{$0}.max() ?? 0
    }
    
    func distance(a: Line.PhotoPercentCoordinate, b: Line.PhotoPercentCoordinate) -> Double {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return sqrt(dx*dx + dy*dy)
    }

    func addProblem(_ problem: Problem) {
        if overlaps(with: problem) {
            problems.append(problem)
        }
    }

    func description() -> String {
        return problems.map { $0.localizedName }.joined(separator: ", ")
    }
    
    var problemsWithoutVariants: [Problem] {
        problems.filter {
            if let parent = $0.parent {
                return !problems.contains(parent)
            }
            else {
                return true
            }
        }
    }
    
    func next(after: Problem) -> Problem? {
//        print(problemsWithoutVariants)
        if let index = problems.firstIndex(of: after) {
            return problems[(index + 1) % problems.count]
        }
        
        return nil
    }
}
