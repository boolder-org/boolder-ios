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
import Combine

// Bridge between SwiftUI-world (driven by MapState) and UIKit-world (MapboxViewController)
// 2 ways to communicate:
// SwiftUI -> UIKit : MapboxView.updateUIViewController
// UIKit -> SwiftUI : MapBoxViewDelegate protocol

struct MapboxView: UIViewControllerRepresentable {
    var mapState: MapState
    
    func makeUIViewController(context: Context) -> MapboxViewController {
        let vc = MapboxViewController()
        vc.delegate = context.coordinator
        context.coordinator.viewController = vc
        return vc
    }
    
    func updateUIViewController(_ vc: MapboxViewController, context: Context) {
        // Handle selectedProblem changes
        let selectedId = mapState.selectedProblem.id
        if context.coordinator.lastSelectedProblemId != selectedId && selectedId != 0 {
            context.coordinator.lastSelectedProblemId = selectedId
            vc.setProblemAsSelected(problemFeatureId: String(selectedId))
        }
        
        // Handle centerOnProblem changes
        if let centerOnProblem = mapState.centerOnProblem {
            let centerOnProblemId = centerOnProblem.id
            if context.coordinator.lastCenterOnProblemId != centerOnProblemId {
                context.coordinator.lastCenterOnProblemId = centerOnProblemId
                vc.centerOnProblem(centerOnProblem)
            }
        }
        
        // Handle centerOnArea changes
        if let centerOnArea = mapState.centerOnArea {
            let centerOnAreaId = centerOnArea.id
            if context.coordinator.lastCenterOnAreaId != centerOnAreaId {
                context.coordinator.lastCenterOnAreaId = centerOnAreaId
                vc.centerOnArea(centerOnArea)
            }
        }
        
        // Handle centerOnCurrentLocation changes
        if mapState.currentLocationCount != context.coordinator.lastCurrentLocationCount {
            context.coordinator.lastCurrentLocationCount = mapState.currentLocationCount
            vc.centerOnCurrentLocation()
        }
        
        // Handle centerOnCircuit changes
        if let centerOnCircuit = mapState.centerOnCircuit {
            let centerOnCircuitId = centerOnCircuit.id
            if context.coordinator.lastCenterOnCircuitId != centerOnCircuitId {
                context.coordinator.lastCenterOnCircuitId = centerOnCircuitId
                vc.centerOnCircuit(centerOnCircuit)
            }
        }
        else {
            vc.unselectCircuit()
        }

        // Handle selectedCircuit changes
        if let selectedCircuit = mapState.selectedCircuit {
            let selectedCircuitId = selectedCircuit.id
            if context.coordinator.lastSelectedCircuitId != selectedCircuitId {
                context.coordinator.lastSelectedCircuitId = selectedCircuitId
                vc.setCircuitAsSelected(circuit: selectedCircuit)
            }
        }
        else {
            if context.coordinator.lastSelectedCircuitId != 0 {
                context.coordinator.lastSelectedCircuitId = 0
                vc.unselectCircuit()
            }
        }
        
        // Handle refreshFilters changes
        if mapState.refreshFiltersCount != context.coordinator.lastRefreshFiltersCount {
            context.coordinator.lastRefreshFiltersCount = mapState.refreshFiltersCount
            vc.applyFilters(mapState.filters)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: Coordinator
    
    class Coordinator: MapBoxViewDelegate {
        var parent: MapboxView
        var viewController: MapboxViewController?
        
        var lastSelectedProblemId: Int = 0
        var lastCenterOnProblemId: Int = 0
        var lastCenterOnAreaId: Int = 0
        var lastCurrentLocationCount: Int = 0
        var lastCenterOnCircuitId: Int = 0
        var lastSelectedCircuitId: Int = 0
        var lastRefreshFiltersCount: Int = 0

        init(_ parent: MapboxView) {
            self.parent = parent
        }
        
        func selectProblem(id: Int) {
            if let problem = Problem.load(id: id) {
                parent.mapState.selectProblem(problem)
                parent.mapState.presentProblemDetails = true
            }
        }
        
        func selectArea(id: Int) {
            if let area = Area.load(id: id) {
                parent.mapState.selectArea(area)
            }
        }
        
        func selectCluster(id: Int) {
            if let cluster = Cluster.load(id: id) {
                parent.mapState.selectCluster(cluster)
            }
        }
        
        func unselectArea() {
            parent.mapState.unselectArea()
        }
        
        func unselectCluster() {
            parent.mapState.unselectCluster()
        }
        
        func unselectCircuit() {
            parent.mapState.unselectCircuit()
        }
        
        func selectPoi(name: String, location: CLLocationCoordinate2D, googleUrl: String) {
            // FIXME: use short name or long name?
            // FIXME: don't use id=0
            let poi = Poi(id: 0, type: .parking, name: name, shortName: name, googleUrl: googleUrl, coordinate: location)
            parent.mapState.selectedPoi = poi
            parent.mapState.presentPoiActionSheet = true
        }
        
        func dismissProblemDetails() {
            parent.mapState.presentProblemDetails = false
        }
        
        func cameraChanged(state: MapboxMaps.CameraState) {
            if parent.mapState.displayCircuitStartButton {
                parent.mapState.displayCircuitStartButton = false
            }
            
            // TODO: deal with padding
            parent.mapState.updateCameraState(center: state.center, zoom: state.zoom)
        }
    }
}
