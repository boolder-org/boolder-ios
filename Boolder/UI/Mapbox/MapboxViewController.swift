//
//  MapboxViewController.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/10/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import UIKit
import MapboxMaps

class MapboxViewController: UIViewController {
    
    var mapView: MapView!
    var delegate: MapBoxViewDelegate!
    private var previouslyTappedProblemId: String = ""
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let myResourceOptions = ResourceOptions(accessToken: "pk.eyJ1Ijoibm1vbmRvbGxvdCIsImEiOiJjbDlyNHo2OGMwZjNyM3ZsNzk5d2M1NDVlIn0.HUjcpmT5EZyhuR_VjN6eog")

        let cameraOptions = CameraOptions(
            center: CLLocationCoordinate2D(latitude: 48.394842, longitude: 2.6318405),
            zoom: 10
        )
        
        let myMapInitOptions = MapInitOptions(
            resourceOptions: myResourceOptions,
            cameraOptions: cameraOptions,
            styleURI: StyleURI(rawValue: "mapbox://styles/nmondollot/cl95n147u003k15qry7pvfmq2/draft")

        )
        
        mapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Wait for the map to load its style before adding data.
        mapView.mapboxMap.onNext(event: .mapLoaded) { [self] _ in
            
            // Specify a unique string as the source ID (SOURCE_ID)
            let sourceIdentifier = "problems"
            var source = VectorSource()
            // In this case, the tileset is owned by the "mapbox" account
            // and "mapbox-terrain-v2" is the tileset ID
            source.url = "mapbox://nmondollot.4xsv235p"
            source.promoteId = .string("id")
            // Add the vector source to the style
            try! self.mapView.mapboxMap.style.addSource(source, id: sourceIdentifier)
            
            //            // Define bounding box
            //            let bounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: 48.2868427, longitude: 2.4806787),
            //                                          northeast: CLLocationCoordinate2D(latitude: 48.473906, longitude: 2.7698927))
            //
            //            // Center the camera on the bounds
            //            let cameraOptions = mapView.mapboxMap.camera(for: bounds, padding: .zero, bearing: 0, pitch: 0)
            //            mapView.mapboxMap.setCamera(to: cameraOptions)
            
            
            // Specify a unique string as the layer ID ("LAYER_ID")
            // and set the source to some source ID (SOURCE_ID).
            var problemsLayer = CircleLayer(id: "problems")
            problemsLayer.source = "problems"
            problemsLayer.sourceLayer = "problems-ayes3a"
            problemsLayer.minZoom = 15
            problemsLayer.filter = Expression(.match) {
                ["geometry-type"]
                ["Point"]
                true
                false
            }
            
            // Set some style properties
            problemsLayer.circleRadius = .expression(
                
                Exp(.interpolate) {
                    ["linear"]
                    ["zoom"]
                    15
                    2
                    18
                    4
                    22
                    16
                }
                
            )
            
            problemsLayer.circleColor = .expression(
                Exp(.match) {
                    Exp(.get) { "circuitColor" }
                    "yellow"
                    Circuit.CircuitColor.yellow.uicolor
                    "purple"
                    Circuit.CircuitColor.purple.uicolor
                    "orange"
                    Circuit.CircuitColor.orange.uicolor
                    "green"
                    Circuit.CircuitColor.green.uicolor
                    "blue"
                    Circuit.CircuitColor.blue.uicolor
                    "skyblue"
                    Circuit.CircuitColor.skyBlue.uicolor
                    "salmon"
                    Circuit.CircuitColor.salmon.uicolor
                    "red"
                    Circuit.CircuitColor.red.uicolor
                    "black"
                    Circuit.CircuitColor.black.uicolor
                    "white"
                    Circuit.CircuitColor.white.uicolor
                    Circuit.CircuitColor.offCircuit.uicolor
                }
            )
            
            problemsLayer.circleStrokeWidth = .expression(
                Exp(.switchCase) {
                    Exp(.boolean) {
                        Exp(.featureState) { "selected" }
                        false
                    }
                    3.0
                    0.0
                }
            )
            problemsLayer.circleStrokeColor = .constant(StyleColor(UIColor.appGreen))
            
            let stopsB: [Double: Double] = [
                14.5: 0.0,
                15:   1.0,
            ]
            problemsLayer.circleOpacity = .expression(
                Exp(.interpolate) {
                    ["linear"]
                    ["zoom"]
                    stopsB
                }
            )
            
            // Add the circle layer to the map.
            try! self.mapView.mapboxMap.style.addLayer(problemsLayer)
            
            
            var problemsTextsLayer = SymbolLayer(id: "problems-texts")
            problemsTextsLayer.source = "problems"
            problemsTextsLayer.sourceLayer = "problems-ayes3a"
            problemsTextsLayer.minZoom = 19
            problemsTextsLayer.filter = Expression(.match) {
                ["geometry-type"]
                ["Point"]
                true
                false
            }
            
            problemsTextsLayer.textAllowOverlap = .constant(true)
            problemsTextsLayer.textField = .expression(
                Expression(.toString) {
                    ["get", "circuitNumber"]
                }
            )
            
            let stopsC: [Double: Double] = [
                19: 10,
                22: 20,
            ]
            problemsTextsLayer.textSize = .expression(
                Exp(.interpolate) {
                    ["linear"]
                    ["zoom"]
                    stopsC
                }
            )
            
            problemsTextsLayer.textColor = .expression(
                Expression(.switchCase) {
                    Expression(.match) {
                        ["get", "circuitColor"]
                        ["", "white"]
                        true
                        false
                    }
                    UIColor.black // use less dark
                    UIColor.white
                }
            )
            
            
            try! self.mapView.mapboxMap.style.addLayer(problemsTextsLayer)
            
//            applyFilter()
            
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.findFeatures))
            self.mapView.addGestureRecognizer(tapGesture)
        }
        
        self.view.addSubview(mapView)
    }
    
    func applyFilter() {
        do {
          
          try mapView.mapboxMap.style.updateLayer(withId: "problems", type: CircleLayer.self) { layer in
            // Update layer properties
              layer.filter = Expression(.match) {
                  Exp(.get) { "grade" }
                  ["1a","1a+","1b","1b+","1c","1c+","2a","2a+","2b","2b+","2c","2c+","3a","3a+","3b","3b+","3c","3c+",]
                  true
                  false
              }
          }
            
            try mapView.mapboxMap.style.updateLayer(withId: "problems-texts", type: SymbolLayer.self) { layer in
              // Update layer properties
                layer.filter = Expression(.match) {
                    Exp(.get) { "grade" }
                    ["1a","1a+","1b","1b+","1c","1c+","2a","2a+","2b","2b+","2c","2c+","3a","3a+","3b","3b+","3c","3c+",]
                    true
                    false
                }
            }
        } catch {
          print("Ran into an error updating the layer: \(error)")
        }
    }
    
    func removeFilter() {
        do {
        try mapView.mapboxMap.style.updateLayer(withId: "problems", type: CircleLayer.self) { layer in
          // Update layer properties
            layer.filter = Expression(.match) {
                Exp(.get) { "grade" }
                ["1a","1a+","1b","1b+","1c","1c+","2a","2a+","2b","2b+","2c","2c+","3a","3a+","3b","3b+","3c","3c+","4a","4a+","4b","4b+","4c","4c+","5a","5a+","5b","5b+","5c","5c+","6a","6a+","6b","6b+","6c","6c+","7a","7a+","7b","7b+","7c","7c+","8a","8a+","8b","8b+","8c","8c+","9a","9a+","9b","9b+","9c","9c+",]
                true
                false
            }
        }
          
          try mapView.mapboxMap.style.updateLayer(withId: "problems-texts", type: SymbolLayer.self) { layer in
            // Update layer properties
              layer.filter = Expression(.match) {
                  Exp(.get) { "grade" }
                  ["1a","1a+","1b","1b+","1c","1c+","2a","2a+","2b","2b+","2c","2c+","3a","3a+","3b","3b+","3c","3c+","4a","4a+","4b","4b+","4c","4c+","5a","5a+","5b","5b+","5c","5c+","6a","6a+","6b","6b+","6c","6c+","7a","7a+","7b","7b+","7c","7c+","8a","8a+","8b","8b+","8c","8c+","9a","9a+","9b","9b+","9c","9c+",]
                  true
                  false
              }
          }
      } catch {
        print("Ran into an error updating the layer: \(error)")
      }
    }
    
    func setProblemAsSelected(problemFeatureId: String) {
        
        
        self.mapView.mapboxMap.setFeatureState(sourceId: "problems",
                                               sourceLayerId: "problems-ayes3a",
                                               featureId: problemFeatureId,
                                               state: ["selected": true])
        
        

        if problemFeatureId != self.previouslyTappedProblemId {
            unselectPreviousProblem()
        }
        
        self.previouslyTappedProblemId = problemFeatureId
    }
    
    func unselectPreviousProblem() {
        if(self.previouslyTappedProblemId != "") {
            self.mapView.mapboxMap.setFeatureState(sourceId: "problems",
                                                   sourceLayerId: "problems-ayes3a",
                                                   featureId: self.previouslyTappedProblemId,
                                                   state: ["selected": false])
        }
    }
    
    
    @objc public func findFeatures(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: mapView)

        let zoomExpressionForAreas = Expression(.lt) {
            Expression(.zoom)
            15
        }

        mapView.mapboxMap.queryRenderedFeatures(
            with: tapPoint,
            options: RenderedQueryOptions(layerIds: ["areas", "areas-hulls"], filter: zoomExpressionForAreas)) { [weak self] result in

                guard let self = self else { return }

                switch result {
                case .success(let queriedfeatures):

                    if let feature = queriedfeatures.first?.feature,
                       case .string(let southWestLon) = feature.properties?["southWestLon"],
                       case .string(let southWestLat) = feature.properties?["southWestLat"],
                       case .string(let northEastLon) = feature.properties?["northEastLon"],
                       case .string(let northEastLat) = feature.properties?["northEastLat"]
                    {
//                        print(areaFeature.properties)

                        // Define bounding box
                        let bounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: Double(southWestLat) ?? 0, longitude: Double(southWestLon) ?? 0),
                                                      northeast: CLLocationCoordinate2D(latitude: Double(northEastLat) ?? 0, longitude: Double(northEastLon) ?? 0))

                        // Center the camera on the bounds
                        let cameraOptions = self.mapView.mapboxMap.camera(for: bounds, padding: .init(top: 16, left: 16, bottom: 16, right: 16), bearing: 0, pitch: 0)
                        self.mapView.camera.fly(to: cameraOptions, duration: 0.5)
                    }
                case .failure(let error):
                    print("An error occurred: \(error.localizedDescription)")
                }
            }
        
        let zoomExpressionForClusters = Expression(.lte) {
            Expression(.zoom)
            12
        }
        
        mapView.mapboxMap.queryRenderedFeatures(
            with: tapPoint,
            options: RenderedQueryOptions(layerIds: ["clusters"], filter: nil)) { [weak self] result in
                
//                print("tap cluster")
                
                guard let self = self else { return }
                
                switch result {
                case .success(let queriedfeatures):
                    
                    if let feature = queriedfeatures.first?.feature,
                       case .string(let southWestLon) = feature.properties?["southWestLon"],
                       case .string(let southWestLat) = feature.properties?["southWestLat"],
                       case .string(let northEastLon) = feature.properties?["northEastLon"],
                       case .string(let northEastLat) = feature.properties?["northEastLat"]
                    {
//                        print(areaFeature.properties)

                        // Define bounding box
                        let bounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: Double(southWestLat) ?? 0, longitude: Double(southWestLon) ?? 0),
                                                      northeast: CLLocationCoordinate2D(latitude: Double(northEastLat) ?? 0, longitude: Double(northEastLon) ?? 0))
                        
                        // Center the camera on the bounds
                        let cameraOptions = self.mapView.mapboxMap.camera(for: bounds, padding: .init(top: 16, left: 16, bottom: 16, right: 16), bearing: 0, pitch: 0)
                        self.mapView.camera.fly(to: cameraOptions, duration: 0.5)
                    }
                case .failure(let error):
                    print("An error occurred: \(error.localizedDescription)")
                }
            }
        
        mapView.mapboxMap.queryRenderedFeatures(
            with: tapPoint,
            options: RenderedQueryOptions(layerIds: ["problems"], filter: nil)) { [weak self] result in
                
//                print("tap on problems layer")

            guard let self = self else { return }

            switch result {
            case .success(let queriedfeatures):

                // Extract the earthquake feature from the queried features
                if let problemFeature = queriedfeatures.first?.feature,
//                   case .number(let problemIdDouble) = problemFeature.identifier,
                   case .number(let id) = problemFeature.properties?["id"],
                   case .point(let point) = problemFeature.geometry
//                   case let .number(magnitude) = problemFeature.properties?["mag"]
                {
                    
//                    print(problemFeature.properties)
//
//                    print(id)
//                    print(point)
                    
//                    print(String(id))
                    
                    self.delegate?.selectProblem(id: Int(id)) // FIXME: make sure we cast to Int before running the rest of the code
                    
//                    let cameraOptions = CameraOptions(
//                        center: point.coordinates,
//                        padding: UIEdgeInsets(top: 0, left: 0, bottom: self.view.bounds.height/2, right: 0)
//                    )
//                    self.mapView.camera.fly(to: cameraOptions, duration: 0.2)
                    
                    self.setProblemAsSelected(problemFeatureId: String(Int(id)))


//                    let earthquakeId = Int(earthquakeIdDouble).description
//
//                    // Set the description of the earthquake from the `properties` object
//                    self.setDescription(magnitude: magnitude, timeStamp: timestamp, location: place)
//
//                    // Set the earthquake to be "selected"
//                    self.setSelectedState(earthquakeId: earthquakeId)
//
//                    // Reset a previously tapped earthquake to be "unselected".
//                    self.resetPreviouslySelectedStateIfNeeded(currentTappedEarthquakeId: earthquakeId)
//
//                    // Store the currently tapped earthquake so it can be reset when another earthquake is tapped.
//                    self.previouslyTappedEarthquakeId = earthquakeId
//
//                    // Center the selected earthquake on the screen
//                    self.mapView.camera.fly(to: CameraOptions(center: point.coordinates, zoom: 10))
                }
                else {
                    self.unselectPreviousProblem()
                }
            case .failure(let error):
                print("An error occurred: \(error.localizedDescription)")
            }
        }
    }
}

protocol MapBoxViewDelegate {

    // Define expected delegate functions
    func selectProblem(id: Int)
}
