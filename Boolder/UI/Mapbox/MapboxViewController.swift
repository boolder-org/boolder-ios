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
            
            
            
            
          // Specify a unique string as the layer ID ("LAYER_ID")
          // and set the source to some source ID (SOURCE_ID).
          var circleLayer = CircleLayer(id: "problems")
          circleLayer.source = "problems"
            circleLayer.sourceLayer = "problems-ayes3a"
          // Set some style properties
          circleLayer.circleRadius = .constant(2)
          circleLayer.circleColor = .constant(StyleColor(.red))
          // Add the circle layer to the map.
            try! self.mapView.mapboxMap.style.addLayer(circleLayer)
        }
        
        self.view.addSubview(mapView)
    }
}
