//
//  MapboxViewController.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/10/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import UIKit
import MapboxMaps
import CoreLocation

class MapboxViewController: UIViewController {
    
    var mapView: MapView!
    var delegate: MapBoxViewDelegate?
    private var previouslyTappedProblemId: String = ""
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let myResourceOptions = ResourceOptions(accessToken: "pk.eyJ1Ijoibm1vbmRvbGxvdCIsImEiOiJjbDlyNHo2OGMwZjNyM3ZsNzk5d2M1NDVlIn0.HUjcpmT5EZyhuR_VjN6eog")
        
        let cameraOptions = CameraOptions(
            center: CLLocationCoordinate2D(latitude: 48.3925623, longitude: 2.5968216),
            zoom: 10.2
        )
        
        let myMapInitOptions = MapInitOptions(
            resourceOptions: myResourceOptions,
            cameraOptions: cameraOptions,
            styleURI: StyleURI(rawValue: "mapbox://styles/nmondollot/cl95n147u003k15qry7pvfmq2")
        )
        
        mapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let configuration = Puck2DConfiguration.makeDefault(showBearing: true)
        mapView.location.options.puckType = .puck2D(configuration)
        
        mapView.gestures.options.pitchEnabled = false
        mapView.gestures.options.simultaneousRotateAndPinchZoomEnabled = false
        
        mapView.ornaments.options.scaleBar.visibility = .hidden
        mapView.ornaments.options.compass.margins = CGPoint(x: 16, y: 64)
        
        mapView.ornaments.options.attributionButton.position = .bottomLeading
        mapView.ornaments.options.attributionButton.margins = CGPoint(x: -4, y: 6)
        mapView.ornaments.options.logo.margins = CGPoint(x: 36, y: 8)
        
        // Wait for the map to load its style before adding data.
        mapView.mapboxMap.onNext(event: .mapLoaded) { [self] _ in
            self.addSources()
            self.addLayers()
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.findFeatures))
            self.mapView.addGestureRecognizer(tapGesture)
        }
        
        mapView.mapboxMap.onEvery(event: .cameraChanged) { [self] _ in
            if(mapView.mapboxMap.cameraState.zoom < 15) {
                delegate?.unselectArea()
            }
        }
        
        self.view.addSubview(mapView)
    }
    
    let problemsSourceLayerId = "problems-ayes3a" // name of the layer in the mapbox tileset
    
    func addSources() {
        var source = VectorSource()
        source.url = "mapbox://nmondollot.4xsv235p"
        source.promoteId = .string("id") // needed to make Feature-State work

        do {
            try self.mapView.mapboxMap.style.addSource(source, id: "problems")
        }
        catch {
            print("Ran into an error adding the sources: \(error)")
        }
    }
    
    func addLayers() {
        var problemsLayer = CircleLayer(id: "problems")
        problemsLayer.source = "problems"
        problemsLayer.sourceLayer = problemsSourceLayerId
        problemsLayer.minZoom = 15
        problemsLayer.filter = Expression(.match) {
            ["geometry-type"]
            ["Point"] // don't display boulders (stored in the tileset as LineStrings)
            true
            false
        }
        
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
        
        problemsLayer.circleSortKey = .expression(
            Exp(.switchCase) {
                Exp(.boolean) {
                    Exp(.has) { "circuitId" }
                    false
                }
                2
                1
            }
        )
        
        var problemsTextsLayer = SymbolLayer(id: "problems-texts")
        problemsTextsLayer.source = "problems"
        problemsTextsLayer.sourceLayer = problemsSourceLayerId
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
        
        problemsTextsLayer.textSize = .expression(
            Exp(.interpolate) {
                ["linear"]
                ["zoom"]
                19
                10
                22
                20
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
                UIColor.black // TODO: less dark
                UIColor.white
            }
        )
        
        do {
            try self.mapView.mapboxMap.style.addLayer(problemsLayer) // TODO: use layerPosition like on the web?
            try self.mapView.mapboxMap.style.addLayer(problemsTextsLayer)
        }
        catch {
            print("Ran into an error adding the layers: \(error)")
        }
    }
    
    func applyFilters(_ filters: Filters) {
        do {
            let gradeMin = filters.gradeRange?.min ?? Grade.min
            let gradeMax = filters.gradeRange?.max ?? Grade.max
            
            let gradesArray = (gradeMin...gradeMax).map{ $0.string }
            
            try ["problems", "problems-texts"].forEach { layerId in
                try mapView.mapboxMap.style.updateLayer(withId: layerId, type: CircleLayer.self) { layer in
                    layer.filter = Expression(.match) {
                        Exp(.get) { "grade" }
                        gradesArray
                        true
                        false
                    }
                }
            }
 
        } catch {
            print("Ran into an error updating the layer: \(error)")
        }
    }
    
    func setProblemAsSelected(problemFeatureId: String) {
        self.mapView.mapboxMap.setFeatureState(sourceId: "problems",
                                               sourceLayerId: problemsSourceLayerId,
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
                                                   sourceLayerId: problemsSourceLayerId,
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
                       case .number(let id) = feature.properties?["areaId"],
                       case .string(let southWestLon) = feature.properties?["southWestLon"],
                       case .string(let southWestLat) = feature.properties?["southWestLat"],
                       case .string(let northEastLon) = feature.properties?["northEastLon"],
                       case .string(let northEastLat) = feature.properties?["northEastLat"]
                    {
                        let bounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: Double(southWestLat) ?? 0, longitude: Double(southWestLon) ?? 0),
                                                      northeast: CLLocationCoordinate2D(latitude: Double(northEastLat) ?? 0, longitude: Double(northEastLon) ?? 0))
                        
                        let cameraOptions = self.mapView.mapboxMap.camera(for: bounds, padding: .init(top: 60, left: 8, bottom: 8, right: 8), bearing: 0, pitch: 0)
                        self.mapView.camera.fly(to: cameraOptions, duration: 0.5)
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.delegate?.selectArea(id: Int(id))
                        }
                    }
                case .failure(let error):
                    print("An error occurred: \(error.localizedDescription)")
                }
            }
        
        mapView.mapboxMap.queryRenderedFeatures(
            with: tapPoint,
            options: RenderedQueryOptions(layerIds: ["clusters"], filter: nil)) { [weak self] result in
                
                guard let self = self else { return }
                
                switch result {
                case .success(let queriedfeatures):
                    
                    if let feature = queriedfeatures.first?.feature,
                       case .string(let southWestLon) = feature.properties?["southWestLon"],
                       case .string(let southWestLat) = feature.properties?["southWestLat"],
                       case .string(let northEastLon) = feature.properties?["northEastLon"],
                       case .string(let northEastLat) = feature.properties?["northEastLat"]
                    {
                        let bounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: Double(southWestLat) ?? 0, longitude: Double(southWestLon) ?? 0),
                                                      northeast: CLLocationCoordinate2D(latitude: Double(northEastLat) ?? 0, longitude: Double(northEastLon) ?? 0))
                        
                        let cameraOptions = self.mapView.mapboxMap.camera(for: bounds, padding: .init(top: 60, left: 8, bottom: 8, right: 8), bearing: 0, pitch: 0)
                        self.mapView.camera.fly(to: cameraOptions, duration: 0.5)
                    }
                case .failure(let error):
                    print("An error occurred: \(error.localizedDescription)")
                }
            }
        
        mapView.mapboxMap.queryRenderedFeatures(
            with: tapPoint,
            options: RenderedQueryOptions(layerIds: ["pois"], filter: nil)) { [weak self] result in
                
                guard let self = self else { return }
                
                switch result {
                case .success(let queriedfeatures):
                    
                    if let feature = queriedfeatures.first?.feature,
                       case .string(let name) = feature.properties?["name"],
                       case .string(let googleUrl) = feature.properties?["googleUrl"],
                       case .point(let point) = feature.geometry
                    {
                        self.delegate?.selectPoi(name: name, location: point.coordinates, googleUrl: googleUrl)
                    }
                case .failure(let error):
                    print("An error occurred: \(error.localizedDescription)")
                }
            }
        
        mapView.mapboxMap.queryRenderedFeatures(
            with: CGRect(x: tapPoint.x-16, y: tapPoint.y-16, width: 32, height: 32),
            options: RenderedQueryOptions(layerIds: ["problems"], filter: nil)) { [weak self] result in
                
                guard let self = self else { return }
                
                if self.mapView.mapboxMap.cameraState.zoom < 18 { return }
                
                switch result {
                case .success(let queriedfeatures):
                    
                    if let feature = queriedfeatures.first?.feature,
                       case .number(let id) = feature.properties?["id"],
                       case .point(let point) = feature.geometry
                    {
                        self.delegate?.selectProblem(id: Int(id))
                        self.setProblemAsSelected(problemFeatureId: String(Int(id)))
                        
                        // if problem is hidden by the bottom sheet
                        if tapPoint.y >= self.mapView.bounds.height/2 {
                            
                            let cameraOptions = CameraOptions(
                                center: point.coordinates,
                                padding: UIEdgeInsets(top: 60, left: 0, bottom: self.view.bounds.height/2, right: 0)
                            )
                            self.mapView.camera.ease(to: cameraOptions, duration: 0.5)
                        }
                    }
                    else {
                        self.unselectPreviousProblem()
                        self.delegate?.dismissProblemDetails()
                    }
                case .failure(let error):
                    print("An error occurred: \(error.localizedDescription)")
                }
            }
    }
}

import CoreLocation

protocol MapBoxViewDelegate {
    func selectProblem(id: Int)
    func selectPoi(name: String, location: CLLocationCoordinate2D, googleUrl: String)
    func selectArea(id: Int)
    func unselectArea()
    func dismissProblemDetails()
}
