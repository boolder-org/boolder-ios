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
// SwiftUI -> UIKit : MapboxView.Coordinator.subscribeToMapState()
// UIKit -> SwiftUI : MapBoxViewDelegate protocol

struct MapboxView: UIViewControllerRepresentable {
    @ObservedObject var mapState: MapState
    
    func makeUIViewController(context: Context) -> MapboxViewController {
        let vc = MapboxViewController()
        vc.delegate = context.coordinator
        context.coordinator.viewController = vc
        return vc
    }
    
    func updateUIViewController(_ vc: MapboxViewController, context: Context) {
        
//        // select problem
//        if mapState.selectProblemCount > context.coordinator.lastSelectProblemCount {
//            vc.setProblemAsSelected(problemFeatureId: String(mapState.selectedProblem.id))
//            context.coordinator.lastSelectProblemCount = mapState.selectProblemCount
//        }
//        
//        // center on problem
//        if mapState.centerOnProblemCount > context.coordinator.lastCenterOnProblemCount {
//            if let problem = mapState.centerOnProblem {
//                vc.centerOnProblem(problem)
//                context.coordinator.lastCenterOnProblemCount = mapState.centerOnProblemCount
//            }
//        }
//        
//        // center on area
//        if mapState.centerOnAreaCount > context.coordinator.lastCenterOnAreaCount {
//            if let area = mapState.centerOnArea {
//                vc.centerOnArea(area)
//                context.coordinator.lastCenterOnAreaCount = mapState.centerOnAreaCount
//            }
//        }
//        
//        // center on current location
//        if mapState.centerOnCurrentLocationCount > context.coordinator.lastCenterOnCurrentLocationCount {
//            vc.centerOnCurrentLocation()
//            context.coordinator.lastCenterOnCurrentLocationCount = mapState.centerOnCurrentLocationCount
//        }
//        
//        // select a circuit
//        if mapState.selectCircuitCount > context.coordinator.lastSelectCircuitCount {
//            if let circuit = mapState.selectedCircuit {
//                vc.setCircuitAsSelected(circuit: circuit)
//            }
//            else {
//                vc.unselectCircuit()
//            }
//            context.coordinator.lastSelectCircuitCount = mapState.selectCircuitCount
//        }
//        
//        // center on circuit
//        if mapState.centerOnCircuitCount > context.coordinator.lastCenterOnCircuitCount {
//            
//            if let circuit = mapState.selectedCircuit {
//                vc.centerOnCircuit(circuit)
//            }
//            else {
//                vc.unselectCircuit()
//            }
//            context.coordinator.lastCenterOnCircuitCount = mapState.centerOnCircuitCount
//        }
//        
//        // refresh filters
//        if(mapState.filtersRefreshCount > context.coordinator.lastFiltersRefreshCount) {
//            vc.applyFilters(mapState.filters)
//            context.coordinator.lastFiltersRefreshCount = mapState.filtersRefreshCount
//        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: Coordinator
    
    class Coordinator: MapBoxViewDelegate {
        var parent: MapboxView
        var viewController: MapboxViewController?
        private var cancellables = Set<AnyCancellable>()

        init(_ parent: MapboxView) {
            self.parent = parent
            subscribeToMapState()
        }
        
        private func subscribeToMapState() {
            parent.mapState.$selectedProblem
                .sink { [weak self] problem in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.viewController?.setProblemAsSelected(problemFeatureId: String(self.parent.mapState.selectedProblem.id))
                    }
                }
                .store(in: &cancellables)
            
            parent.mapState.$centerOnProblem
                .sink { [weak self] problem in
                    guard let self = self else { return }
                    if let problem = problem {
                        DispatchQueue.main.async {
                            self.viewController?.centerOnProblem(problem)
                        }
                    }
                }
                .store(in: &cancellables)
            
            parent.mapState.$centerOnArea
                .sink { [weak self] area in
                    guard let self = self else { return }
                    if let area = area {
                        DispatchQueue.main.async {
                            self.viewController?.centerOnArea(area)
                        }
                    }
                }
                .store(in: &cancellables)
            
            parent.mapState.$currentLocation
                .sink { [weak self] centerOnCurrentLocation in
                    guard let self = self else { return }
                    if centerOnCurrentLocation {
                        DispatchQueue.main.async {
                            self.viewController?.centerOnCurrentLocation()
                        }
                    }
                }
                .store(in: &cancellables)
            
            parent.mapState.$centerOnCircuit
                .sink { [weak self] circuit in
                    guard let self = self else { return }
                    if let circuit = circuit {
                        DispatchQueue.main.async {
                            self.viewController?.centerOnCircuit(circuit)
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.viewController?.unselectCircuit()
                        }
                    }
                }
                .store(in: &cancellables)
            
            parent.mapState.$selectedCircuit
                .sink { [weak self] circuit in
                    guard let self = self else { return }
                    if let circuit = circuit {
                        DispatchQueue.main.async {
                            self.viewController?.setCircuitAsSelected(circuit: circuit)
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.viewController?.unselectCircuit()
                        }
                    }
                }
                .store(in: &cancellables)
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
            let poi = Poi(id: 0, type: .parking, name: name, shortName: name, googleUrl: googleUrl)
            parent.mapState.selectedPoi = poi
            parent.mapState.presentPoiActionSheet = true
        }
        
        func dismissProblemDetails() {
            parent.mapState.presentProblemDetails = false
        }
        
        func cameraChanged(state: MapboxMaps.CameraState) {
            parent.mapState.displayCircuitStartButton = false
            
            // TODO: deal with padding
            parent.mapState.updateCameraState(center: state.center, zoom: state.zoom)
        }
    }
}
