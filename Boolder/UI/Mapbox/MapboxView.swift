//
//  MapboxView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/10/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import MapboxMaps

struct MapboxView: UIViewControllerRepresentable {
//    typealias UIViewControllerType = MapboxViewController
//    @EnvironmentObject var sqliteStore: SqliteStore
    
    @Binding var selectedProblem: Problem
    @Binding var presentProblemDetails: Bool
    @Binding var centerOnProblem: Problem?
    @Binding var centerOnProblemCount: Int
    
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
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: Coordinator
    
    class Coordinator: MapBoxViewDelegate {
        var parent: MapboxView
        
        var lastCenterOnProblemCount = 0
        
        init(_ parent: MapboxView) {
            self.parent = parent
        }
        
        func selectProblem(id: Int) {
            print("selected problem \(id)")
            
            let problem = Problem.loadProblem(id: id)
            
            parent.selectedProblem = problem
            parent.presentProblemDetails = true
        }

    }

}
