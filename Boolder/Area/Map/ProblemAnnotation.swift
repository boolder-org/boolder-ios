//
//  ProblemAnnotation.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/03/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import MapKit
import CoreData

class ProblemAnnotation: NSObject, MKAnnotation {
    // This property must be key-value observable, which the `@objc dynamic` attributes provide.
    @objc dynamic var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    // FIXME: re-think the way to handle the defaults (use enums? don't use nil values?)
    var title: String?
    var displayLabel: String = ""
    var circuitType: Circuit.CircuitType?
    var identifier: String?
    var belongsToCircuit: Bool = false
    var grade: Grade?
    var name: String? = nil
    var height: Int? = nil
    var steepness: Steepness.SteepnessType = .other
    var id: Int!
    var topo: Topo?
    var tags: [String]?
    
    func readableDescription() -> String? {
        var strings = Set<String>()
        
        if let tags = tags {
            strings.formUnion(tags)
            strings.remove("risky") // FIXME: use enum
        }
        
        if let height = height {
            strings.insert("hauteur \(height)m")
        }
        
        return strings.map { (string: String) in
            switch string {
            case "sit_start":
                return "départ assis"
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
    
    func topoFirstPoint() -> Topo.PhotoPercentCoordinate? {
        guard let topo = topo else { return nil }
        guard let line = topo.line else { return nil }
        guard let firstPoint = line.first else { return nil }
        
        return firstPoint
    }
    
    // FIXME: use Color
    func displayColor() -> UIColor {
        guard let circuitType = circuitType else { return UIColor.gray }
        
        return Circuit(circuitType).color
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
    
    func isFavorite() -> Bool {
        favorite() != nil
    }
    
    func favorite() -> Favorite? {
        DataStore.shared.favorites().first { (favorite: Favorite) -> Bool in
            return Int(favorite.problemId) == self.id
        }
    }
}

//class ProblemAnnotation: NSObject, Decodable, MKAnnotation {
//
//    private var latitude: CLLocationDegrees = 0
//    private var longitude: CLLocationDegrees = 0
//
//    // This property must be key-value observable, which the `@objc dynamic` attributes provide.
//    @objc dynamic var coordinate: CLLocationCoordinate2D {
//        get {
//            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//        }
//        set {
//            // For most uses, `coordinate` can be a standard property declaration without the customized getter and setter shown here.
//            // The custom getter and setter are needed in this case because of how it loads data from the `Decodable` protocol.
//            latitude = newValue.latitude
//            longitude = newValue.longitude
//        }
//    }
//}

