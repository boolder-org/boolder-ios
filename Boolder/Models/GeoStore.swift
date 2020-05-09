//
//  GeoStore.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import MapKit

class GeoStore {

    var circuits = [Circuit]()
    var overlays: [MKOverlay]
    var annotations: [ProblemAnnotation]
    var groupedAnnotations: Dictionary<Int, [ProblemAnnotation]>

    init() {
        overlays = [MKOverlay]()
        annotations = [ProblemAnnotation]()
        groupedAnnotations = Dictionary<Int, [ProblemAnnotation]>()
        
        loadData()
    }
    
    func loadData() {        
        if let geojsonUrl = Bundle.main.url(forResource: "area-\(areaId)-data", withExtension: "geojson") {
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

            if let feature = object as? MKGeoJSONFeature {
                
                var type: String?
                var id: Int?
                
                if let first = feature.identifier?.split(separator: "_").first, let last = feature.identifier?.split(separator: "_").last {
                    type = String(first)
                    id = Int(last)
                }
                
                if type == "circuit", let id = id {
                    parseCircuit(feature: feature, id: id)
                }
                else if type == "boulder", let id = id {
                    parseBoulder(feature: feature, id: id)
                }
                else if type == "problem", let id = id {
                    parseProblem(feature: feature, id: id)
                }
                else {
                    print("Could not parse feature with identifier: \(feature.identifier ?? "")")
                }
            }
        }
    }
    
    private func parseCircuit(feature: MKGeoJSONFeature, id: Int) {
        for geometry in feature.geometry {
            if let polyline = geometry as? MKPolyline, let properties = feature.properties {
                
                let decoder = JSONDecoder()
                if let dictionary = try? decoder.decode([String: String].self, from: properties) {
                    let overlay = CircuitOverlay(points: polyline.points(), count: polyline.pointCount)
                    let circuit = Circuit(type: Circuit.circuitTypeFromString(dictionary["color"]), name: dictionary["name"] ?? "Sans nom", overlay: overlay)
                    overlay.strokeColor = circuit.color
                    circuits.append(circuit)
                }
            }
        }
    }
    
    private func parseBoulder(feature: MKGeoJSONFeature, id: Int) {
        for geometry in feature.geometry {
            if let polygon = geometry as? MKPolygon {
                overlays.append(MKMultiPolygon([polygon]))
            }
//            else if let multiPolygon = geometry as? MKMultiPolygon {
//                overlays.append(multiPolygon)
//            }
        }
    }
    
    private func parseProblem(feature: MKGeoJSONFeature, id: Int) {
        for geometry in feature.geometry {
            
            if let point = geometry as? MKPointAnnotation, let properties = feature.properties {
                
                let annotation = ProblemAnnotation()
                annotation.id = id
                annotation.coordinate = point.coordinate
                
                let decoder = JSONDecoder()
                if let properties = try? decoder.decode(ProblemProperties.self, from: properties) {
                    
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
                    
                    if let topo = properties.topos?.first {
                        annotation.topoId = topo.id
                    }
                    
                    annotation.tags = properties.tags
                    
                    annotation.circuitType = Circuit.circuitTypeFromString(properties.circuit)
                }
                
                annotations.append(annotation)
            }
        }
    }
    
    struct ProblemProperties: Decodable {
        let circuit: String?
        let circuitNumber: String?
        let grade: String?
        let name: String?
        let steepness: String?
        let height: Int?
        let topos: [TopoRef]?
        let tags: [String]?
        
        struct TopoRef: Decodable {
            let id: Int
        }
    }
}
