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
                let cameraOptions = vc.mapView.mapboxMap.camera(for: bounds, padding: .init(top: 160, left: 20, bottom: 80, right: 20), bearing: 0, pitch: 0)
                
                vc.flyinToSomething = true
                print("flyin 1 \(vc.flyinToSomething)")
                vc.mapView.camera.fly(to: cameraOptions, duration: 1) { _ in
                    print("flyin 2 \(vc.flyinToSomething)")
                    vc.flyinToSomething = false
                    print("flyin 3 \(vc.flyinToSomething)")
                    
                }
                
                context.coordinator.lastCenterOnAreaCount = mapState.centerOnAreaCount
            }
        }
        
        // center on current location
        if mapState.centerOnCurrentLocationCount > context.coordinator.lastCenterOnCurrentLocationCount {
            if let location = vc.mapView.location.latestLocation {
                let cameraOptions = CameraOptions(
                    center: location.coordinate,
                    padding: .init(top: 160, left: 20, bottom: 80, right: 20),
                    zoom: 16
                )
                vc.flyinToSomething = true
                vc.mapView.camera.fly(to: cameraOptions, duration: 2)  { _ in vc.flyinToSomething = false }
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
            
//            print("coucou")
            
            if let circuit = mapState.selectedCircuit {
//                vc.setCircuitAsSelected(circuit: circuit)
                
                let bounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: circuit.southWestLat, longitude: circuit.southWestLon),
                                              northeast: CLLocationCoordinate2D(latitude: circuit.northEastLat, longitude: circuit.northEastLon))
                let cameraOptions = vc.mapView.mapboxMap.camera(for: bounds, padding: .init(top: 160, left: 20, bottom: 80, right: 20), bearing: 0, pitch: 0)
                vc.flyinToSomething = true
                vc.mapView.camera.fly(to: cameraOptions, duration: 1) { _ in vc.flyinToSomething = false }
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
            let poi = Poi(name: name, coordinate: location, googleUrl: googleUrl)
            parent.mapState.selectedPoi = poi
            parent.mapState.presentPoiActionSheet = true
        }
        
        @MainActor func dismissProblemDetails() {
            parent.mapState.presentProblemDetails = false
        }
    }
}
