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
    
    // FIXME: remove
    static let empty = Problem(id: 0, name: "", grade: Grade.min, coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), steepness: .other, sitStart: false, areaId: 0, circuitId: nil, circuitColor: .offCircuit, circuitNumber: "", bleauInfoId: nil, featured: false, popularity: 0, parentId: nil)
    
    var circuitUIColor: UIColor {
        circuitColor?.uicolor ?? UIColor.gray
    }
    
    var circuitUIColorForPhotoOverlay: UIColor {
        circuitColor?.uicolorForPhotoOverlay ?? UIColor.gray
    }
    
    var nameWithFallback: String {
        if let circuitColor = circuitColor {
            if circuitNumber != "" {
                return name ?? (circuitColor.shortName + " " + circuitNumber)
            }
            else {
                return name ?? NSLocalizedString("problem.no_name", comment: "")
            }
        }
        else {
            return name ?? NSLocalizedString("problem.no_name", comment: "")
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
            return Array(
                Set([parent]).union(
                    Set(parent.children).subtracting(Set([self]))
                )
            )
        }
        else {
            return children
        }
    }

    // TODO: move to Line
    func lineFirstPoint() -> Line.PhotoPercentCoordinate? {
        guard let line = line else { return nil }
        guard let coordinates = line.coordinates else { return nil }
        guard let firstPoint = coordinates.first else { return nil }
        
        return firstPoint
    }
    
    var mainTopoPhoto: UIImage? {
        line?.photo()
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
            
            return problemsOnSameTopo.compactMap{$0}.filter { p in
                p.id != id // don't show itself
                && (p.parentId == nil) // don't show anyone's children
                && (p.id != parentId) // don't show problem's parent
            }
        }
        catch {
            print (error)
            return []
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
