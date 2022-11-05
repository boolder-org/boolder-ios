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
//    typealias UIViewControllerType = MapboxViewController
//    @EnvironmentObject var sqliteStore: SqliteStore
    
    @Binding var selectedProblem: Problem
    @Binding var presentProblemDetails: Bool
    @Binding var centerOnProblem: Problem?
    @Binding var centerOnProblemCount: Int
    @Binding var centerOnArea: AreaItem?
    @Binding var centerOnAreaCount: Int
    @Binding var selectedPoi: Poi?
    @Binding var presentPoiActionSheet: Bool
    
    @Binding var applyFilters: Bool
     
    func makeUIViewController(context: Context) -> MapboxViewController {
        let vc = MapboxViewController()
        vc.delegate = context.coordinator
        return vc
    }
      
    func updateUIViewController(_ vc: MapboxViewController, context: Context) {
        print("update UI")
        
        
        if(applyFilters) {
            vc.applyFilter()
        }
        else {
            vc.removeFilter()
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
                
                let bounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: Double(area.bounds.south_west.lat), longitude: Double(area.bounds.south_west.lng)),
                                              northeast: CLLocationCoordinate2D(latitude: Double(area.bounds.north_east.lat), longitude: Double(area.bounds.north_east.lng)))
                let cameraOptions = vc.mapView.mapboxMap.camera(for: bounds, padding: .init(top: 16, left: 16, bottom: 16, right: 16), bearing: 0, pitch: 0)
                vc.mapView.camera.fly(to: cameraOptions, duration: 1)
                
                
                context.coordinator.lastCenterOnAreaCount = centerOnAreaCount
            }
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
        
        init(_ parent: MapboxView) {
            self.parent = parent
        }
        
        func selectProblem(id: Int) {
            print("selected problem \(id)")
            
            let problem = Problem.loadProblem(id: id)
            
            parent.selectedProblem = problem
            parent.presentProblemDetails = true
        }
        
        func selectPoi(name: String, location: CLLocationCoordinate2D, googleUrl: String) {
            
            let poi = Poi(name: name, coordinate: location, googleUrl: googleUrl)
            parent.selectedPoi = poi
            parent.presentPoiActionSheet = true
        }

    }

}
