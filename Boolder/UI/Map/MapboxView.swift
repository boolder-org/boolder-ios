//
//  MapboxView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/10/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import CoreLocation
import MapboxMaps

// Bridge between SwiftUI-world (driven by MapState) and UIKit-world (MapboxViewController)
// 2 ways to communicate:
// SwiftUI -> UIKit : updateUIViewController
// UIKit -> SwiftUI : MapBoxViewDelegate

struct MapboxView: UIViewControllerRepresentable {
    let mapState: MapState
    
    func makeUIViewController(context: Context) -> MapboxViewController {
        let vc = MapboxViewController()
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ vc: MapboxViewController, context: Context) {
        
        // refresh filters
        if(mapState.filtersRefreshCount > context.coordinator.lastFiltersRefreshCount) {
            vc.applyFilters(mapState.filters)
            context.coordinator.lastFiltersRefreshCount = mapState.filtersRefreshCount
        }
        
        // center on problem
        if mapState.centerOnProblemCount > context.coordinator.lastCenterOnProblemCount {
            if let problem = mapState.centerOnProblem {
                
                let cameraOptions = CameraOptions(
                    center: problem.coordinate,
                    padding: UIEdgeInsets(top: 60, left: 0, bottom: vc.view.bounds.height/2, right: 0),
                    zoom: 20
                )
                // FIXME: quick fix to make the circuit mode work => change the duration logic for other cases
                vc.flyinToSomething = true
                vc.mapView.camera.fly(to: cameraOptions, duration: 0.5) { _ in vc.flyinToSomething = false }
                
                context.coordinator.lastCenterOnProblemCount = mapState.centerOnProblemCount
            }
        }
        
        // center on area
        if mapState.centerOnAreaCount > context.coordinator.lastCenterOnAreaCount {
            if let area = mapState.centerOnArea {
                
                let bounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: area.southWestLat, longitude: area.southWestLon),
                                              northeast: CLLocationCoordinate2D(latitude: area.northEastLat, longitude: area.northEastLon))

                
                var cameraOptions = vc.mapView.mapboxMap.camera(for: bounds, padding: .init(top: 180, left: 20, bottom: 80, right: 20), bearing: 0, pitch: 0)
                cameraOptions.zoom = max(15, cameraOptions.zoom ?? 0)
                
                vc.flyinToSomething = true
                vc.mapView.camera.fly(to: cameraOptions, duration: 1) { _ in
                    vc.flyinToSomething = false
                }
                
                context.coordinator.lastCenterOnAreaCount = mapState.centerOnAreaCount
            }
        }
        
        // center on current location
        if mapState.centerOnCurrentLocationCount > context.coordinator.lastCenterOnCurrentLocationCount {
            if let location = vc.mapView.location.latestLocation {
                
                let fontainebleauBounds = CoordinateBounds(
                    southwest: CLLocationCoordinate2D(latitude: 48.241596, longitude: 2.3936456),
                    northeast: CLLocationCoordinate2D(latitude: 48.5075073, longitude: 2.7616875)
                )
                
                if fontainebleauBounds.contains(forPoint: location.coordinate, wrappedCoordinates: false) {
                    let cameraOptions = CameraOptions(
                        center: location.coordinate,
                        padding: .init(top: 180, left: 20, bottom: 80, right: 20),
                        zoom: 17
                    )
                    
                    vc.flyinToSomething = true
                    vc.mapView.camera.fly(to: cameraOptions, duration: 0.5)  { _ in vc.flyinToSomething = false }
                    
                    // FIXME: make sure the fly animation is over
                    // TODO: do it again when map is done loading?
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        vc.inferAreaFromMap()
                    }
                }
                else {
                    let cameraOptions = vc.mapView.mapboxMap.camera(
                        for: fontainebleauBounds.extend(forPoint: location.coordinate),
                        padding: .init(top: 180, left: 20, bottom: 80, right: 20),
                        bearing: 0,
                        pitch: 0
                    )
                    
                    vc.flyinToSomething = true
                    vc.mapView.camera.fly(to: cameraOptions, duration: 0.5)  { _ in vc.flyinToSomething = false }
                }
            }
            
            context.coordinator.lastCenterOnCurrentLocationCount = mapState.centerOnCurrentLocationCount
        }
        
        // select problem
        if mapState.selectProblemCount > context.coordinator.lastSelectProblemCount {
            vc.setProblemAsSelected(problemFeatureId: String(mapState.selectedProblem.id))
            
            context.coordinator.lastSelectProblemCount = mapState.selectProblemCount
        }
        
        // select a circuit
        if mapState.selectCircuitCount > context.coordinator.lastSelectCircuitCount {
            
//            print("coucou")
            
            if let circuit = mapState.selectedCircuit {
                vc.setCircuitAsSelected(circuit: circuit)
            }
            else {
                vc.unselectCircuit()
            }
            context.coordinator.lastSelectCircuitCount = mapState.selectCircuitCount
        }
        
        // center on circuit
        if mapState.centerOnCircuitCount > context.coordinator.lastCenterOnCircuitCount {
            
            if let circuit = mapState.selectedCircuit {
                
//                let viewport = vc.mapView.mapboxMap.coordinateBounds(for: CameraOptions(cameraState: vc.mapView.cameraState))
                
                let circuitBounds = CoordinateBounds(
                    southwest: CLLocationCoordinate2D(latitude: circuit.southWestLat, longitude: circuit.southWestLon),
                    northeast: CLLocationCoordinate2D(latitude: circuit.northEastLat, longitude: circuit.northEastLon)
                )
                
//                if !viewport.contains(forArea: circuitBounds, wrappedCoordinates: false) {
                    var cameraOptions = vc.mapView.mapboxMap.camera(
                        for: circuitBounds,
                        padding: .init(top: 180, left: 20, bottom: 80, right: 20),
                        bearing: 0,
                        pitch: 0
                    )
                    cameraOptions.zoom = max(15, cameraOptions.zoom ?? 0)
                    
                    vc.flyinToSomething = true
                    vc.mapView.camera.fly(to: cameraOptions, duration: 0.5) { _ in vc.flyinToSomething = false }
//                }
            }
            else {
                vc.unselectCircuit()
            }
            context.coordinator.lastCenterOnCircuitCount = mapState.centerOnCircuitCount
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: Coordinator
    
    class Coordinator: MapBoxViewDelegate {
        var parent: MapboxView
        
        var lastCenterOnProblemCount = 0
        var lastCenterOnAreaCount = 0
        var lastCenterOnCurrentLocationCount = 0
        var lastFiltersRefreshCount = 0
        var lastSelectProblemCount = 0
        var lastSelectCircuitCount = 0
        var lastCenterOnCircuitCount = 0
        
        init(_ parent: MapboxView) {
            self.parent = parent
        }
        
        @MainActor func selectProblem(id: Int) {
            if let problem = Problem.load(id: id) {
                parent.mapState.selectProblem(problem)
                parent.mapState.presentProblemDetails = true
            }
        }
        
        @MainActor func selectArea(id: Int) {
            if let area = Area.load(id: id) {
                parent.mapState.selectedArea = area
            }
        }
        
        @MainActor func unselectArea() {
            parent.mapState.selectedArea = nil
        }
        
        @MainActor func unselectCircuit() {
            parent.mapState.unselectCircuit()
        }
        
        @MainActor func selectPoi(name: String, location: CLLocationCoordinate2D, googleUrl: String) {
            // FIXME: use short name or long name?
            // FIXME: don't use id=0
            let poi = Poi(id: 0, type: .parking, name: name, shortName: name, googleUrl: googleUrl)
            parent.mapState.selectedPoi = poi
            parent.mapState.presentPoiActionSheet = true
        }
        
        @MainActor func dismissProblemDetails() {
            parent.mapState.presentProblemDetails = false
        }
        
        @MainActor func cameraChanged() {
            parent.mapState.displayCircuitStartButton = false
        }
    }
}
