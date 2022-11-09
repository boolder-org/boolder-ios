//
//  Problem.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 09/05/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import UIKit
import MapKit

import CoreData
import SQLite

struct Problem : Identifiable {
    let id: Int
    let name: String?
    let grade: Grade
    var coordinate: CLLocationCoordinate2D
    let steepness: Steepness
    let sitStart: Bool
    let areaId: Int
    let circuitId: Int?
    let circuitColor: Circuit.CircuitColor?
    let circuitNumber: String
    let bleauInfoId: String?
    let parentId: Int?
    
    static let empty = Problem(id: 0, name: "", grade: Grade.min, coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), steepness: .other, sitStart: false, areaId: 0, circuitId: nil, circuitColor: .offCircuit, circuitNumber: "", bleauInfoId: nil, parentId: nil)
    
    static func loadProblem(id: Int) -> Problem? {
        do {
            let db = SqliteStore.shared.db
            
            let problems = Table("problems").filter(Expression(literal: "id = '\(id)'"))
            
            let areaId = Expression<Int>("area_id")
            let name = Expression<String?>("name") // FIXME: use optional?
            let grade = Expression<String>("grade")
            let steepness = Expression<String>("steepness")
            let circuitNumber = Expression<String?>("circuit_number")
            let circuitColor = Expression<String?>("circuit_color")
            let circuitId = Expression<Int?>("circuit_id")
            let bleauInfoId = Expression<String?>("bleau_info_id")
            let parentId = Expression<Int?>("parent_id")
            let latitude = Expression<Double?>("latitude")
            let longitude = Expression<Double?>("longitude")
            let sitStart = Expression<Int>("sit_start")
            
            if let p = try db.pluck(problems) {
                return Problem(
                    id: id,
                    name: p[name],
                    grade: Grade(p[grade]),
                    coordinate: CLLocationCoordinate2D(latitude: p[latitude] ?? 0, longitude: p[longitude] ?? 0),
                    steepness: Steepness(rawValue: p[steepness]) ?? .other,
                    sitStart: p[sitStart] == 1,
                    areaId: p[areaId],
                    circuitId: p[circuitId],
                    circuitColor: Circuit.circuitColorFromString(p[circuitColor]),
                    circuitNumber: p[circuitNumber] ?? "",
                    bleauInfoId: p[bleauInfoId],
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
        circuitColor?.uicolorForPhotoOverlay() ?? UIColor.gray
    }
    
    func nameWithFallback() -> String {
        if let circuitColor = circuitColor {
            if circuitNumber != "" {
                return name ?? (circuitColor.shortName() + " " + circuitNumber)
            }
            else {
                return name ?? NSLocalizedString("problem.no_name", comment: "")
            }
        }
        else {
            return name ?? NSLocalizedString("problem.no_name", comment: "")
        }
    }
    
    // FIXME: this code is called many times => perf issue?
    var line: Line? {
        //        if let lineId = lineId {
        //            return dataStore.topoStore.lineCollection.line(withId: lineId)
        //        }
        //        else
        //        {
        //            return nil
        //        }
        
        //        print("lines")
        
        let db = SqliteStore.shared.db
        
        let lines = Table("lines").filter(Expression(literal: "problem_id = '\(id)'"))
        
        let id = Expression<Int>("id")
        let topoId = Expression<Int>("topo_id")
        let coordinates = Expression<String>("coordinates")
        
        // TODO: handle multiple lines
        if let l = try! db.pluck(lines) {
            //            print(l[id])
            //            print(l[topoId])
            //            print(l[coordinates])
            
            let jsonString = l[coordinates]
            let jsonData = jsonString.data(using: .utf8)
            let coordinates = try! JSONDecoder().decode([Line.PhotoPercentCoordinate]?.self, from: jsonData!)
            
            return Line(id: l[id], topoId: l[topoId], coordinates: coordinates)
        }
        
        return nil
    }
    
    
    var otherProblemsOnSameTopo: [Problem] {
        guard line != nil else { return [] }
        
        let db = SqliteStore.shared.db
        
        let lines = Table("lines").filter(Expression(literal: "topo_id = '\(line!.topoId)'"))
        
        let problemId = Expression<Int>("problem_id")
        
        let problemsOnSameTopo = try! db.prepare(lines).map { l in
            Self.loadProblem(id: l[problemId])
        }
        
        return problemsOnSameTopo.compactMap{$0}.filter { p in
            p.id != id // don't show itself
            && (p.parentId == nil) // don't show anyone's children
            && (p.id != parentId) // don't show problem's parent
        }
    }
    
    // Same logic exists server side: https://github.com/nmondollot/boolder/blob/145d1b7fbebfc71bab6864e081d25082bcbeb25c/app/models/problem.rb#L99-L105
    var variants: [Problem] {
        if let parent = parent {
            //            print(parent)
            return Array(
                Set([parent]).union(
                    Set(parent.children).subtracting(Set([self]))
                )
            )
        }
        else {
            //            print(children)
            return children
        }
    }
    
    var parent: Problem? {
        guard let parentId = parentId else { return nil }
        
        return Self.loadProblem(id: parentId)
    }
    
    var children: [Problem] {
        let db = SqliteStore.shared.db
        
        // FIXME: clean code
        let problems = Table("problems").filter(Expression(literal: "parent_id = '\(id)'"))
        //        print(problems)
        let id = Expression<Int>("id")
        
        //        for p in try! sqliteStore.db.prepare(problems) {
        //            print(p)
        //        }
        
        return try! db.prepare(problems).map { problem in
            Self.loadProblem(id: problem[id])
        }.compactMap{$0}
    }
    
    
    // FIXME: move to Line
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
