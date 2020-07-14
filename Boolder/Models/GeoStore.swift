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
    var boulderOverlays = [BoulderOverlay]()
    var problems = [Problem]()
    var pois = [Poi]()
    var poiRouteOverlays = [PoiRouteOverlay]()
    
    private var areaId: Int

    init(areaId: Int) {
        self.areaId = areaId
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
                else if type == "poi", let id = id {
                    parsePoi(feature: feature, id: id)
                }
                else if type == "poiroute", let id = id {
                    parsePoiRoute(feature: feature, id: id)
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
                    let circuit = Circuit(color: Circuit.circuitColorFromString(dictionary["color"]), level: Circuit.circuitLevelFromString(dictionary["level"]), overlay: overlay)
                    overlay.strokeColor = circuit.color.uicolor
                    circuits.append(circuit)
                }
            }
        }
    }
    
    private func parsePoiRoute(feature: MKGeoJSONFeature, id: Int) {
        for geometry in feature.geometry {
            if let polyline = geometry as? MKPolyline {
                let overlay = PoiRouteOverlay(points: polyline.points(), count: polyline.pointCount)
                poiRouteOverlays.append(overlay)
            }
        }
    }
    
    private func parsePoi(feature: MKGeoJSONFeature, id: Int) {
        for geometry in feature.geometry {
            if let point = geometry as? MKPointAnnotation, let properties = feature.properties {
                
                let decoder = JSONDecoder()
                if let dictionary = try? decoder.decode([String: String].self, from: properties) {
                    
                    let annotation = PoiAnnotation()
                    annotation.coordinate = point.coordinate
                    annotation.title = dictionary["title"]
                    annotation.subtitle = dictionary["subtitle"]
                    
                    let poi = Poi(title: dictionary["title"], subtitle: dictionary["subtitle"], description: dictionary["description"], coordinate: point.coordinate, annotation: annotation)
                    
                    annotation.poi = poi
                    
                    pois.append(poi)
                }
            }
        }
    }
    
    private func parseBoulder(feature: MKGeoJSONFeature, id: Int) {
        for geometry in feature.geometry {
            if let polygon = geometry as? MKPolygon {
                boulderOverlays.append(BoulderOverlay([polygon]))
            }
//            else if let multiPolygon = geometry as? MKMultiPolygon {
//                overlays.append(multiPolygon)
//            }
        }
    }
    
    private func parseProblem(feature: MKGeoJSONFeature, id: Int) {
        for geometry in feature.geometry {
            
            if let point = geometry as? MKPointAnnotation, let properties = feature.properties {
                
                let decoder = JSONDecoder()
                if let properties = try? decoder.decode(ProblemProperties.self, from: properties) {
                    
                    let problem = Problem()
                    
                    problem.circuitNumber = properties.circuitNumber ?? ""
                    problem.name = properties.name
                    
                    if let height = properties.height {
                        problem.height = height
                    }
                    
                    if let steepness = properties.steepness {
                        problem.steepness = Steepness(string: steepness).type
                    }
                    
                    if let gradeString = properties.grade {
                        do { problem.grade = try Grade(gradeString) } catch {  }
                    }
                    
                    if let topo = properties.topos?.first {
                        problem.topoId = topo.id
                    }
                    
                    problem.tags = properties.tags
                    
                    problem.circuitColor = Circuit.circuitColorFromString(properties.circuitColor)
                    
                    problem.id = id
                    
                    let annotation = ProblemAnnotation(problem: problem)
                    annotation.coordinate = point.coordinate
                    
                    problem.annotation = annotation // FIXME: circular reference
                    
                    problems.append(problem)
                }
            }
        }
    }
    
    struct ProblemProperties: Decodable {
        let circuitColor: String?
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
