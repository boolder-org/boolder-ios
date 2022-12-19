//
//  AreaViewModel.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 19/12/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SQLite
import SwiftUI

@MainActor class AreaViewModel : ObservableObject {
    let area: Area
    let mapState: MapState
    
    init(area: Area, mapState: MapState) {
        self.area = area
        self.mapState = mapState
    }
    
    var problems: [Problem] {
        let db = SqliteStore.shared.db
        
        let grade = Expression<String>("grade")
        let popularity = Expression<String>("popularity")
        let problems = Table("problems").filter(Expression(literal: "area_id = '\(area.id)'")).order(popularity.desc)
        let id = Expression<Int>("id")
        
        do {
            return try db.prepare(problems).map { problem in
                Problem.load(id: problem[id])
            }.compactMap{$0}
        }
        catch {
            print (error)
            return []
        }
    }
    
    var circuits: [Circuit] {
        let db = SqliteStore.shared.db
        
        let average_grade = Expression<String>("average_grade")
        let circuits = Table("circuits").order(average_grade.asc).limit(5)
        let id = Expression<Int>("id")
        let color = Expression<String>("color")
        
        do {
            return try db.prepare(circuits).map { circuit in
                Circuit(id: circuit[id], color: Circuit.CircuitColor.colorFromString(circuit[color]))
            }.compactMap{$0}
        }
        catch {
            print (error)
            return []
        }
    }
}
