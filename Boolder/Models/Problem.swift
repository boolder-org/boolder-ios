//
//  Problem.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 09/05/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import UIKit
import MapKit

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
        if let lineId = lineId {
            return dataStore.topoStore.lineCollection.line(withId: lineId)
        }
        else
        {
            return nil
        }
    }
    
    var otherProblemsOnSameTopo: [Problem] {
        guard line != nil else { return [] }
        
        return dataStore.problems.filter { problem in
            (line?.topoId == problem.line?.topoId)
            && (id != problem.id) // don't show itself
            && (problem.parentId == nil) && (problem.id != parentId) // don't show variants
        }
    }
    
    // Same logic exists server side: https://github.com/nmondollot/boolder/blob/145d1b7fbebfc71bab6864e081d25082bcbeb25c/app/models/problem.rb#L99-L105
    var variants: [Problem] {
        if let parentId = parentId {
            return dataStore.problems.filter { problem in
                ((problem.id == parentId) || (problem.parentId == id)) && problem.id != id
            }
        }
        else {
            return dataStore.problems.filter { problem in
                problem.parentId == id
            }
        }
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
