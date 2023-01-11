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
    
    // TODO: find a way to make this DRY
    func updateUIViewController(_ vc: MapboxViewController, context: Context) {
        
        // select problem
        if mapState.selectProblemCount > context.coordinator.lastSelectProblemCount {
            vc.setProblemAsSelected(problemFeatureId: String(mapState.selectedProblem.id))
            context.coordinator.lastSelectProblemCount = mapState.selectProblemCount
        }
        
        // center on problem
        if mapState.centerOnProblemCount > context.coordinator.lastCenterOnProblemCount {
            if let problem = mapState.centerOnProblem {
                vc.centerOnProblem(problem)
                context.coordinator.lastCenterOnProblemCount = mapState.centerOnProblemCount
            }
        }
        
        // center on area
        if mapState.centerOnAreaCount > context.coordinator.lastCenterOnAreaCount {
            if let area = mapState.centerOnArea {
                vc.centerOnArea(area)
                context.coordinator.lastCenterOnAreaCount = mapState.centerOnAreaCount
            }
        }
        
        // center on current location
        if mapState.centerOnCurrentLocationCount > context.coordinator.lastCenterOnCurrentLocationCount {
            vc.centerOnCurrentLocation()
            context.coordinator.lastCenterOnCurrentLocationCount = mapState.centerOnCurrentLocationCount
        }
        
        // select a circuit
        if mapState.selectCircuitCount > context.coordinator.lastSelectCircuitCount {
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
                vc.centerOnCircuit(circuit)
            }
            else {
                vc.unselectCircuit()
            }
            context.coordinator.lastCenterOnCircuitCount = mapState.centerOnCircuitCount
        }
        
        // refresh filters
        if(mapState.filtersRefreshCount > context.coordinator.lastFiltersRefreshCount) {
            vc.applyFilters(mapState.filters)
            context.coordinator.lastFiltersRefreshCount = mapState.filtersRefreshCount
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: Coordinator
    
    class Coordinator: MapBoxViewDelegate {
        var parent: MapboxView
        
        var lastSelectProblemCount = 0
        var lastCenterOnProblemCount = 0
        var lastCenterOnAreaCount = 0
        var lastSelectCircuitCount = 0
        var lastCenterOnCircuitCount = 0
        var lastCenterOnCurrentLocationCount = 0
        var lastFiltersRefreshCount = 0
        
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
                parent.mapState.selectArea(area)
            }
        }
        
        @MainActor func unselectArea() {
            parent.mapState.unselectArea()
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
