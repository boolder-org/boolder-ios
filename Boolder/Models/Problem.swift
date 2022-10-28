//
//  Problem.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 09/05/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import UIKit
import MapKit

import SQLite

class Problem : Identifiable {
    var circuitId: Int?
    var circuitColor: Circuit.CircuitColor?
    var circuitNumber: String = ""
    var belongsToCircuit: Bool = false
    var grade = Grade.min
    var name: String? = nil
    var bleauInfoId: String? = nil
    var parentId: Int? = nil
    var height: Int? = nil
    var steepness: Steepness = .other
    var id: Int!
    var lineId: Int?
    var tags: [String]?
    var annotation: ProblemAnnotation!
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    static func loadProblem(id: String) -> Problem {
        do {
            let db = (UIApplication.shared.delegate as! AppDelegate).sqliteStore.db
            
            let problems = Table("problems").filter(Expression(literal: "id = '\(id)'"))
            
//            let id = Expression<Int>("id")
            let name = Expression<String>("name") // FIXME: use optional?
            let grade = Expression<String>("grade")
            let steepness = Expression<String>("steepness")
            let circuitNumber = Expression<String?>("circuit_number")
            let circuitColor = Expression<String?>("circuit_color")
            let circuitId = Expression<Int?>("circuit_id")
            let bleauInfoId = Expression<String?>("bleau_info_id")
            let parentId = Expression<Int?>("parent_id")
            
            if let p = try! db.pluck(problems) {
                // print(p)
                
                let problem = Problem()
                problem.id = Int(id)
                problem.name = p[name]
                problem.grade = Grade(p[grade])
                problem.steepness = Steepness(rawValue: p[steepness]) ?? .other
                problem.circuitNumber = p[circuitNumber] ?? ""
                problem.circuitColor = Circuit.circuitColorFromString(p[circuitColor])
                
                if let id = p[circuitId] {
                    problem.circuitId = id
                }
                
                if let id2 = p[bleauInfoId] {
                    problem.bleauInfoId = id2
                }
                
                if let id3 = p[parentId] {
                    problem.parentId = id3
                }
                
                return problem
            }
            
            return Problem() // FIXME: handle errors
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
    
    func nameForDirections() -> String {
        if let circuitColor = circuitColor {
            if circuitNumber != "" {
                return circuitColor.shortName() + " " + circuitNumber
            }
        }
        
        return name ?? NSLocalizedString("problem.no_name", comment: "")
    }
    
    func readableDescription() -> String? {
        var strings = Set<String>()
        
        if let tags = tags {
            strings.formUnion(tags)
            strings.remove("risky") // FIXME: use enum
        }
        
//        if let height = height {
//            strings.insert(
//                String.localizedStringWithFormat(NSLocalizedString("problem.height_desc", comment: ""), height.description)
//            )
//        }
        
        return strings.map { (string: String) in
            switch string {
            case "sit_start":
                return NSLocalizedString("problem.sit_start", comment: "")
            default:
                return string
            }
        }.joined(separator: ", ")
    }
    
    func isRisky() -> Bool {
        if let tags = tags {
            return tags.contains("risky") // FIXME: use enum
        }
        return false
    }
    
    var line: Line? {
//        if let lineId = lineId {
//            return dataStore.topoStore.lineCollection.line(withId: lineId)
//        }
//        else
//        {
//            return nil
//        }
        
        print("lines")
        
        let lines = Table("lines").filter(Expression(literal: "problem_id = '\(id!)'"))
        
        let id = Expression<Int>("id")
        let topoId = Expression<Int>("topo_id")
        let coordinates = Expression<String>("coordinates")
        
        if let l = try! sqliteStore.db.pluck(lines) {
            print(l[id])
            print(l[topoId])
            print(l[coordinates])
            
            let jsonString = l[coordinates]
            let jsonData = jsonString.data(using: .utf8)
            let coordinates = try! JSONDecoder().decode([Line.PhotoPercentCoordinate]?.self, from: jsonData!)
            
            return Line(id: l[id], topoId: l[topoId], coordinates: coordinates)
        }
        
        return nil
    }
    
//    struct PhotoPercentCoordinate: Decodable {
//        let x: Double
//        let y: Double
//    }
    
    
    
    var otherProblemsOnSameTopo: [Problem] {
        guard line != nil else { return [] }
        
//        return dataStore.problems.filter { problem in
//            (line?.topoId == problem.line?.topoId)
//            && (id != problem.id) // don't show itself
//            && (problem.parentId == nil) && (problem.id != parentId) // don't show variants
//        }
        
        return []
    }
    
    // Same logic exists server side: https://github.com/nmondollot/boolder/blob/145d1b7fbebfc71bab6864e081d25082bcbeb25c/app/models/problem.rb#L99-L105
    var variants: [Problem] {
//        if let parentId = parentId {
//            return dataStore.problems.filter { problem in
//                ((problem.id == parentId) || (problem.parentId == parentId)) && problem.id != id
//            }
//        }
//        else {
//            return dataStore.problems.filter { problem in
//                problem.parentId == id
//            }
//        }
        return []
    }
    
    func lineFirstPoint() -> Line.PhotoPercentCoordinate? {
        guard let line = line else { return nil }
        guard let coordinates = line.coordinates else { return nil }
        guard let firstPoint = coordinates.first else { return nil }
        
        return firstPoint
    }
    
    var mainTopoPhoto: UIImage? {
        line?.photo()
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
    
    var dataStore: DataStore {
        (UIApplication.shared.delegate as! AppDelegate).dataStore
    }
    
    var sqliteStore: SqliteStore {
        (UIApplication.shared.delegate as! AppDelegate).sqliteStore
    }
    
    func isFavorite() -> Bool {
        favorite() != nil
    }
    
    func favorite() -> Favorite? {
        dataStore.favorites().first { (favorite: Favorite) -> Bool in
            return Int(favorite.problemId) == id
        }
    }
    
    func isTicked() -> Bool {
        tick() != nil
    }
    
    func tick() -> Tick? {
        dataStore.ticks().first { (tick: Tick) -> Bool in
            return Int(tick.problemId) == id
        }
    }
    
}
