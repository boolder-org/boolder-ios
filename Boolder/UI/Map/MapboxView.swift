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
                vc.mapView.camera.fly(to: cameraOptions, duration: 2)
                
                context.coordinator.lastCenterOnProblemCount = mapState.centerOnProblemCount
            }
        }
        
        // center on area
        if mapState.centerOnAreaCount > context.coordinator.lastCenterOnAreaCount {
            if let area = mapState.centerOnArea {
                
                let bounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: area.southWestLat, longitude: area.southWestLon),
                                              northeast: CLLocationCoordinate2D(latitude: area.northEastLat, longitude: area.northEastLon))
                let cameraOptions = vc.mapView.mapboxMap.camera(for: bounds, padding: .init(top: 60, left: 8, bottom: 8, right: 8), bearing: 0, pitch: 0)
                vc.mapView.camera.fly(to: cameraOptions, duration: 1)
                
                context.coordinator.lastCenterOnAreaCount = mapState.centerOnAreaCount
            }
        }
        
        // center on current location
        if mapState.centerOnCurrentLocationCount > context.coordinator.lastCenterOnCurrentLocationCount {
            if let location = vc.mapView.location.latestLocation {
                let cameraOptions = CameraOptions(
                    center: location.coordinate,
                    padding: .init(top: 60, left: 8, bottom: 8, right: 8),
                    zoom: 16
                )
                vc.mapView.camera.fly(to: cameraOptions, duration: 2)
            }
            
            context.coordinator.lastCenterOnCurrentLocationCount = mapState.centerOnCurrentLocationCount
        }
        
        // select problem
        if mapState.selectProblemCount > context.coordinator.lastSelectProblemCount {
            vc.setProblemAsSelected(problemFeatureId: String(mapState.selectedProblem.id))
            
            context.coordinator.lastSelectProblemCount = mapState.selectProblemCount
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
        
        init(_ parent: MapboxView) {
            self.parent = parent
        }
        
        @MainActor func selectProblem(id: Int) {
            if let problem = Problem.load(id: id) {
                parent.mapState.selectedProblem = problem
                parent.mapState.presentProblemDetails = true
            }
        }
        
        @MainActor func selectPoi(name: String, location: CLLocationCoordinate2D, googleUrl: String) {
            let poi = Poi(name: name, coordinate: location, googleUrl: googleUrl)
            parent.mapState.selectedPoi = poi
            parent.mapState.presentPoiActionSheet = true
        }
    }
}
