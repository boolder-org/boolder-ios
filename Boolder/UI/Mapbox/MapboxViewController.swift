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
                    Exp(.switchCase) {
                        Exp(.boolean) {
                            Exp(.has) { "circuitColor" }
                            false
                        }
                        16
                        10
                    }
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
            
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.findFeatures))
            self.mapView.addGestureRecognizer(tapGesture)
        }
        
        self.view.addSubview(mapView)
    }
    
    
    @objc public func findFeatures(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: mapView)

        let zoomExpression = Expression(.lt) {
            Expression(.zoom)
            15
        }
        
        mapView.mapboxMap.queryRenderedFeatures(
            with: tapPoint,
            options: RenderedQueryOptions(layerIds: ["areas", "areas-hulls"], filter: zoomExpression)) { [weak self] result in
                
                guard let self = self else { return }
                
                switch result {
                case .success(let queriedfeatures):
                    
                    if let areaFeature = queriedfeatures.first?.feature
                    {
                        print(areaFeature.properties)
                    }
                case .failure(let error):
                    print("An error occurred: \(error.localizedDescription)")
                }
            }
        
        mapView.mapboxMap.queryRenderedFeatures(
            with: tapPoint,
            options: RenderedQueryOptions(layerIds: ["problems"], filter: nil)) { [weak self] result in

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
                    
                    self.delegate?.selectProblem(id: Int(id))

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
