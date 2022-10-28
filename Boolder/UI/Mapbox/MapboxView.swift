//
//  MapboxView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/10/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import MapboxMaps

import SQLite

struct MapboxView: UIViewControllerRepresentable {
//    @EnvironmentObject var sqliteStore: SqliteStore
    
    @SwiftUI.Binding var selectedProblem: Problem
    @SwiftUI.Binding var presentProblemDetails: Bool
     
    func makeUIViewController(context: Context) -> MapboxViewController {
        let vc = MapboxViewController()
        vc.delegate = context.coordinator
        return vc
    }
      
    func updateUIViewController(_ uiViewController: MapboxViewController, context: Context) {
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
            
//            let db = SqliteStore.db
            
            do {
                //
                let databaseURL = Bundle.main.url(forResource: "boolder", withExtension: "db")!
                let db = try! Connection(databaseURL.path, readonly: true)
                
                let problems = Table("problems").filter(Expression(literal: "id = '\(id)'"))
                
                
                
//                let name: Expression<String> = Expression(literal: "")
                
                if let p = try! db.pluck(problems) {
                    print(p)
                    
//                    let id = Expression<Int>("id")
                    
                    let problem = Problem()
                    problem.name = p[Expression(literal: "\"name\"")]
                    problem.grade = Grade(p[Expression(literal: "\"grade\"")])
//                    problem.steepness = Steepness(rawValue: p[Expression(literal: "\"steepness\"")]) ?? .other
//                    problem.circuitNumber = p[Expression(literal: "\"circuit_number\"")]
//                    problem.circuitColor = Circuit.circuitColorFromString(p[Expression(literal: "\"circuit_color\"")])
//                    problem.circuitId = Int(p[Expression(literal: "\"circuit_id\"")])
//                    problem.bleauInfoId = p[Expression(literal: "\"bleau_info_id\"")]
//                    problem.parentId = Int(p[Expression(literal: "\"parent_id\"")])
                    
                    
                    
                    parent.selectedProblem = problem
                    parent.presentProblemDetails = true
                }
                
            }
        }

    }

}
