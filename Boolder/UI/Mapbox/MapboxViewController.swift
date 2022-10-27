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
    
    internal var mapView: MapView!
    
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
//            problemsLayer.filter =
            problemsLayer.minZoom = 15
            
            let stops: [Double: Double] = [
              15: 2.0,
              18: 4.0,
              22: 16
            ]
            
            // Set some style properties
            problemsLayer.circleRadius = .expression(
                Exp(.interpolate) {
                    ["linear"]
                    ["zoom"]
                    stops
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
            
            
            
            
            
            
            
            // Add the circle layer to the map.
            try! self.mapView.mapboxMap.style.addLayer(problemsLayer)
        }
        
        self.view.addSubview(mapView)
    }
}
