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
    let popularity: Int?
    let parentId: Int?
    
    static let empty = Problem(id: 0, name: "", grade: Grade.min, coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), steepness: .other, sitStart: false, areaId: 0, circuitId: nil, circuitColor: .offCircuit, circuitNumber: "", bleauInfoId: nil, popularity: 0, parentId: nil)
    
    static func load(id: Int) -> Problem? {
        do {
            let db = SqliteStore.shared.db
            
            let problems = Table("problems").filter(Expression(literal: "id = '\(id)'"))
            
            let areaId = Expression<Int>("area_id")
            let name = Expression<String?>("name")
            let grade = Expression<String>("grade")
            let steepness = Expression<String>("steepness")
            let circuitNumber = Expression<String?>("circuit_number")
            let circuitColor = Expression<String?>("circuit_color")
            let circuitId = Expression<Int?>("circuit_id")
            let bleauInfoId = Expression<String?>("bleau_info_id")
            let parentId = Expression<Int?>("parent_id")
            let latitude = Expression<Double>("latitude")
            let longitude = Expression<Double>("longitude")
            let sitStart = Expression<Int>("sit_start")
            let popularity = Expression<Int?>("popularity")
            
            if let p = try db.pluck(problems) {
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
    
    // TODO: handle multiple lines
    var line: Line? {
        let db = SqliteStore.shared.db
        
        let lines = Table("lines").filter(Expression(literal: "problem_id = '\(id)'"))
        
        let id = Expression<Int>("id")
        let topoId = Expression<Int>("topo_id")
        let coordinates = Expression<String>("coordinates")
        
        do {
            if let l = try db.pluck(lines) {
                let jsonString = l[coordinates]
                if let jsonData = jsonString.data(using: .utf8) {
                    let coordinates = try JSONDecoder().decode([Line.PhotoPercentCoordinate]?.self, from: jsonData)
                    
                    return Line(id: l[id], topoId: l[topoId], coordinates: coordinates)
                }
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
        
        let db = SqliteStore.shared.db
        
        let lines = Table("lines").filter(Expression(literal: "topo_id = '\(l.topoId)'"))
        
        let problemId = Expression<Int>("problem_id")
        
        do {
            let problemsOnSameTopo = try db.prepare(lines).map { l in
                Self.load(id: l[problemId])
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
    
    var parent: Problem? {
        guard let parentId = parentId else { return nil }
        
        return Self.load(id: parentId)
    }
    
    var children: [Problem] {
        let db = SqliteStore.shared.db
        
        let problems = Table("problems").filter(Expression(literal: "parent_id = '\(id)'"))
        let id = Expression<Int>("id")
        
        do {
            return try db.prepare(problems).map { problem in
                Self.load(id: problem[id])
            }.compactMap{$0}
        }
        catch {
            print (error)
            return []
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
    
    var next: Problem? {
        let db = SqliteStore.shared.db
        
        let id = Expression<Int>("id")
        let circuitId = Expression<Int>("circuit_id")
        let circuitnumber = Expression<String>("circuit_number")
        let problems = Table("problems")
        
        let nextNumber = String(Int(self.circuitNumber)! + 1)
        let query = problems.filter(circuitId == self.circuitId!).filter(circuitnumber == nextNumber)
        
        if let p = try! db.pluck(query) {
            return Problem.load(id: p[id])
        }
        
        return nil
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
