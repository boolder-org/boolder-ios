//
//  ProblemDataSource.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/03/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import UIKit
import MapKit

struct ProblemProperties: Decodable {
    let circuit: String?
    let circuitNumber: String?
    let grade: String?
    let name: String?
    let steepness: String?
    let id: Int
    let height: Int?
    let topos: [TopoRef]?
    
    struct TopoRef: Decodable {
        let id: Int
    }
}

struct TopoCollection: Decodable {
    let topos: [Topo]?
    
    func topo(withId id: Int) -> Topo? {
        return topos?.first(where: { topo in
            topo.id == id
        })
    }
}

class ProblemDataSource {

    var overlays: [MKOverlay]
    var annotations: [ProblemAnnotation]
    var topoCollection: TopoCollection
    var circuitFilter: Circuit.CircuitType?
    var filters: Filters

    init(circuitFilter: Circuit.CircuitType?, filters: Filters) {
        overlays = [MKOverlay]()
        annotations = [ProblemAnnotation]()
        topoCollection = TopoCollection.init(topos: nil)
        
        self.circuitFilter = circuitFilter
        self.filters = filters
        
        if let topojsonUrl = Bundle.main.url(forResource: "area-1-topos", withExtension: "json") {
            do {
                let jsonData = try Data(contentsOf: topojsonUrl)
                topoCollection = try! JSONDecoder().decode(TopoCollection.self, from: jsonData)

            } catch {
                print("Error decoding topos json: \(error).")
            }
        }

        if let geojsonUrl = Bundle.main.url(forResource: "area-1-data", withExtension: "geojson") {
            do {
                let eventData = try Data(contentsOf: geojsonUrl)
                let decoder = MKGeoJSONDecoder()
                let jsonObjects = try decoder.decode(eventData)

                parse(jsonObjects)

            } catch {
                print("Error decoding GeoJSON: \(error).")
            }
        }
    }

    private func parse(_ jsonObjects: [MKGeoJSONObject]) {
        for object in jsonObjects {

            /*
             In this sample's GeoJSON data there are only features in the
             top-level so this parse method only checks for those. In a generic
             parser, check for geometry objects here too.
            */
            if let feature = object as? MKGeoJSONFeature {
                for geometry in feature.geometry {

                    /*
                     Separate out annotation objects from overlay objects
                     because they are added to the map view in different ways.
                     This sample GeoJSON only contains points and multipolygon
                     geometry. In a generic parser, check for all possible
                     geometry types.
                    */
                    if let multiPolygon = geometry as? MKMultiPolygon {
                        overlays.append(multiPolygon)
                    } else if let polygon = geometry as? MKPolygon {
                        overlays.append(MKMultiPolygon([polygon]))
                    } else if let polyline = geometry as? MKPolyline {
                        let circuitOverlay = CircuitOverlay(points: polyline.points(), count: polyline.pointCount)
                        configure(circuitOverlay: circuitOverlay, using: feature.properties)
                        if(circuitOverlay.circuitType == circuitFilter) {
                            overlays.append(circuitOverlay)
                        }
                    } else if let point = geometry as? MKPointAnnotation {

                        /*
                         The name of the annotation is passed in the feature
                         properties. Parse the name and apply it to the
                         annotation.
                        */
                        
                        let problem = ProblemAnnotation()
                        problem.coordinate = point.coordinate
                        
                        configure(annotation: problem, using: feature.properties)
                        
                        if(circuitFilter == nil || problem.circuitType == circuitFilter) {
                            if let gradeCategory = problem.grade?.category() {
                                if filters.gradeCategories.isEmpty || filters.gradeCategories.contains(gradeCategory) {
                                    if filters.steepness.contains(problem.steepness) {
                                        if filters.photoPresent == false || problem.isPhotoPresent() {
                                            if isHeightOk(problem) {
                                                annotations.append(problem)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func isHeightOk(_ problem: ProblemAnnotation) -> Bool {
        if filters.heightMax == 6 { return true }
        
        if let height = problem.height {
            return (height <= filters.heightMax)
        }
        else {
            return false
        }
    }

    private func configure(annotation: ProblemAnnotation, using properties: Data?) {
        guard let properties = properties else {
            return
        }

        let decoder = JSONDecoder()
        if let properties = try? decoder.decode(ProblemProperties.self, from: properties) {
            // FIXME: refactor
            
            annotation.displayLabel = properties.circuitNumber ?? ""
            annotation.name = properties.name
            
            if let height = properties.height {
                annotation.height = height
            }
            
            if let steepness = properties.steepness {
                annotation.steepness = Steepness(string: steepness).type
            }
            
            if let gradeString = properties.grade {
                do { annotation.grade = try Grade(gradeString) } catch {  }
            }
            
            annotation.id = properties.id
            
            if let topo = properties.topos?.first {
                annotation.topo = topoCollection.topo(withId: topo.id)
            }
            
//            if let line = properties.photoLine {
//                annotation.photoLine = line.map{ProblemAnnotation.PhotoPercentCoordinate(x: $0.x, y: $0.y)}
//            }
            
//            annotation.title = " "
//            annotation.subtitle = annotation.grade
            
            annotation.circuitType = Circuit.circuitTypeFromString(properties.circuit)
            annotation.belongsToCircuit = (circuitFilter == annotation.circuitType)
        }
        else {
            print("Could not parse properties for MKPointAnnotation: \(annotation)")
        }
    }
    
    // FIXME: make DRY
    private func configure(circuitOverlay: CircuitOverlay, using properties: Data?) {
        guard let properties = properties else {
            return
        }

        let decoder = JSONDecoder()
        if let dictionary = try? decoder.decode([String: String].self, from: properties) {
            circuitOverlay.circuitType = Circuit.circuitTypeFromString(dictionary["circuit"])
        }
    }
}

