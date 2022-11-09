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
    @Binding var selectedProblem: Problem
    @Binding var presentProblemDetails: Bool
    @Binding var centerOnProblem: Problem?
    @Binding var centerOnProblemCount: Int
    @Binding var centerOnArea: Area?
    @Binding var centerOnAreaCount: Int
    @Binding var centerOnCurrentLocationCount: Int
    @Binding var selectedPoi: Poi?
    @Binding var presentPoiActionSheet: Bool
    @Binding var filters: Filters
    @Binding var refreshFiltersCount: Int
    
     
    func makeUIViewController(context: Context) -> MapboxViewController {
        let vc = MapboxViewController()
        vc.delegate = context.coordinator
        return vc
    }
      
    func updateUIViewController(_ vc: MapboxViewController, context: Context) {
        print("update UI")
        
        
        if(refreshFiltersCount > context.coordinator.lastRefreshFiltersCount) {
            vc.applyFilters(filters)
            context.coordinator.lastRefreshFiltersCount = refreshFiltersCount
        }
        
        // center on problem
        if centerOnProblemCount > context.coordinator.lastCenterOnProblemCount {
            if let problem = centerOnProblem {
                
                let cameraOptions = CameraOptions(
                    center: problem.coordinate,
                    padding: UIEdgeInsets(top: 0, left: 0, bottom: vc.view.bounds.height/2, right: 0),
                    zoom: 20
                )
                vc.mapView.camera.fly(to: cameraOptions, duration: 2)
                
                vc.setProblemAsSelected(problemFeatureId: String(problem.id))
                
                context.coordinator.lastCenterOnProblemCount = centerOnProblemCount
            }
        }
        
        // center on area
        if centerOnAreaCount > context.coordinator.lastCenterOnAreaCount {
            if let area = centerOnArea {
                
                let bounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: area.southWestLat, longitude: area.southWestLon),
                                              northeast: CLLocationCoordinate2D(latitude: area.northEastLat, longitude: area.northEastLon))
                let cameraOptions = vc.mapView.mapboxMap.camera(for: bounds, padding: .init(top: 16, left: 16, bottom: 16, right: 16), bearing: 0, pitch: 0)
                vc.mapView.camera.fly(to: cameraOptions, duration: 1)
                
                
                context.coordinator.lastCenterOnAreaCount = centerOnAreaCount
            }
        }
        
        // zoom on current location
        if centerOnCurrentLocationCount > context.coordinator.lastCenterOnCurrentLocationCount {
            if let location = vc.mapView.location.latestLocation {
                let cameraOptions = CameraOptions(
                    center: location.coordinate,
                    padding: .zero,
                    zoom: 16
                )
                vc.mapView.camera.fly(to: cameraOptions, duration: 2)
            }
            
            context.coordinator.lastCenterOnCurrentLocationCount = centerOnCurrentLocationCount
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
        var lastRefreshFiltersCount = 0
        
        init(_ parent: MapboxView) {
            self.parent = parent
        }
        
        func selectProblem(id: Int) {
            print("selected problem \(id)")
            
            if let problem = Problem.loadProblem(id: id) {   
                parent.selectedProblem = problem
                parent.presentProblemDetails = true
            }
        }
        
        func selectPoi(name: String, location: CLLocationCoordinate2D, googleUrl: String) {
            
            let poi = Poi(name: name, coordinate: location, googleUrl: googleUrl)
            parent.selectedPoi = poi
            parent.presentPoiActionSheet = true
        }
        
    }

}
