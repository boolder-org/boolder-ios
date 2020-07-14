//
//  Problem.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 09/05/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import UIKit

class Problem : Identifiable {
    var circuitColor: Circuit.CircuitColor?
    var circuitNumber: String = ""
    var belongsToCircuit: Bool = false
    var grade: Grade?
    var name: String? = nil
    var height: Int? = nil
    var steepness: Steepness.SteepnessType = .other
    var id: Int!
    var topoId: Int?
    var tags: [String]?
    var annotation: ProblemAnnotation!
    
    var circuitUIColor: UIColor {
        circuitColor?.uicolor ?? UIColor.gray
    }
    
    func nameWithFallback() -> String {
        self.name ?? NSLocalizedString("no_name", comment: "")
    }
    
    func readableDescription() -> String? {
        var strings = Set<String>()
        
        if let tags = tags {
            strings.formUnion(tags)
            strings.remove("risky") // FIXME: use enum
        }
        
        if let height = height {
            strings.insert(
                String.localizedStringWithFormat(NSLocalizedString("height_desc", comment: ""), height.description)
            )
        }
        
        return strings.map { (string: String) in
            switch string {
            case "sit_start":
                return NSLocalizedString("sit_start", comment: "")
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
    
    var topo: Topo? {
        if let topoId = topoId {
            return dataStore.topoStore.topoCollection.topo(withId: topoId)
        }
        else
        {
            return nil
        }
    }
    
    func topoFirstPoint() -> Topo.PhotoPercentCoordinate? {
        guard let topo = topo else { return nil }
        guard let line = topo.line else { return nil }
        guard let firstPoint = line.first else { return nil }
        
        return firstPoint
    }
    
    func isPhotoPresent() -> Bool {
        topo?.photo() != nil
    }
    
    func mainTopoPhoto() -> UIImage {
        if let topoPhoto = topo?.photo() {
            return topoPhoto
        }
        else {
            return UIImage(named: "placeholder.png")!
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
    
    var dataStore: DataStore {
        (UIApplication.shared.delegate as! AppDelegate).dataStore
    }
    
    func isFavorite() -> Bool {
        favorite() != nil
    }
    
    func favorite() -> Favorite? {
        dataStore.favorites().first { (favorite: Favorite) -> Bool in
            return Int(favorite.problemId) == self.id
        }
    }
    
    func isTicked() -> Bool {
        tick() != nil
    }
    
    func tick() -> Tick? {
        dataStore.ticks().first { (tick: Tick) -> Bool in
            return Int(tick.problemId) == self.id
        }
    }
    
}
