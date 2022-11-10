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
    let appState: AppState
    
    func makeUIViewController(context: Context) -> MapboxViewController {
        let vc = MapboxViewController()
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ vc: MapboxViewController, context: Context) {
        if(appState.filtersRefreshCount > context.coordinator.lastFiltersRefreshCount) {
            vc.applyFilters(appState.filters)
            context.coordinator.lastFiltersRefreshCount = appState.filtersRefreshCount
        }
        
        // center on problem
        if appState.centerOnProblemCount > context.coordinator.lastCenterOnProblemCount {
            if let problem = appState.centerOnProblem {
                
                let cameraOptions = CameraOptions(
                    center: problem.coordinate,
                    padding: UIEdgeInsets(top: 0, left: 0, bottom: vc.view.bounds.height/2, right: 0),
                    zoom: 20
                )
                vc.mapView.camera.fly(to: cameraOptions, duration: 2)
                
                vc.setProblemAsSelected(problemFeatureId: String(problem.id))
                
                context.coordinator.lastCenterOnProblemCount = appState.centerOnProblemCount
            }
        }
        
        // center on area
        if appState.centerOnAreaCount > context.coordinator.lastCenterOnAreaCount {
            if let area = appState.centerOnArea {
                
                let bounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: area.southWestLat, longitude: area.southWestLon),
                                              northeast: CLLocationCoordinate2D(latitude: area.northEastLat, longitude: area.northEastLon))
                let cameraOptions = vc.mapView.mapboxMap.camera(for: bounds, padding: .init(top: 16, left: 16, bottom: 16, right: 16), bearing: 0, pitch: 0)
                vc.mapView.camera.fly(to: cameraOptions, duration: 1)
                
                
                context.coordinator.lastCenterOnAreaCount = appState.centerOnAreaCount
            }
        }
        
        // zoom on current location
        if appState.centerOnCurrentLocationCount > context.coordinator.lastCenterOnCurrentLocationCount {
            if let location = vc.mapView.location.latestLocation {
                let cameraOptions = CameraOptions(
                    center: location.coordinate,
                    padding: .zero,
                    zoom: 16
                )
                vc.mapView.camera.fly(to: cameraOptions, duration: 2)
            }
            
            context.coordinator.lastCenterOnCurrentLocationCount = appState.centerOnCurrentLocationCount
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
        
        init(_ parent: MapboxView) {
            self.parent = parent
        }
        
        @MainActor func selectProblem(id: Int) {
            if let problem = Problem.load(id: id) {
                parent.appState.selectedProblem = problem
                parent.appState.presentProblemDetails = true
            }
        }
        
        @MainActor func selectPoi(name: String, location: CLLocationCoordinate2D, googleUrl: String) {
            let poi = Poi(name: name, coordinate: location, googleUrl: googleUrl)
            parent.appState.selectedPoi = poi
            parent.appState.presentPoiActionSheet = true
        }
    }
}
