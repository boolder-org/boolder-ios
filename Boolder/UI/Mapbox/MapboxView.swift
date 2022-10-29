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
    
    @Binding var applyFilters: Bool
     
    func makeUIViewController(context: Context) -> MapboxViewController {
        let vc = MapboxViewController()
        vc.delegate = context.coordinator
        return vc
    }
      
    func updateUIViewController(_ uiViewController: MapboxViewController, context: Context) {
        print("update UI")
        
        if(applyFilters) {
            uiViewController.applyFilter()
        }
        else {
            uiViewController.removeFilter()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: Coordinator
    
    class Coordinator: MapBoxViewDelegate {
        var parent: MapboxView
        
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
