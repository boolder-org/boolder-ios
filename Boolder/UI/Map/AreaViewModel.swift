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
        
//        let stmt = try db.prepare("SELECT area_id, email FROM users")
//        for row in stmt {
//            for (index, name) in stmt.columnNames.enumerated() {
//                print ("\(name):\(row[index]!)")
//                // id: Optional(1), email: Optional("alice@mac.com")
//            }
//        }
        
        let id = Expression<Int>("id")
        let circuit_id = Expression<Int>("circuit_id")
        let area_id = Expression<Int>("area_id")
        let average_grade = Expression<String>("average_grade")
        let circuits = Table("circuits")
        let problems = Table("problems")
        let color = Expression<String>("color")
        
        let query = circuits.select(circuits[id], circuits[color], circuits[average_grade], problems[id].count)
            .join(problems, on: circuits[id] == problems[circuit_id])
            .group(circuits[id], having: problems[id].count >= 10)
            .filter(problems[area_id] == area.id)
            .order(average_grade.asc)
        
//        print(query.asSQL())

        do {
            return try db.prepare(query).map { circuit in
                Circuit(
                    id: circuit[id],
                    color: Circuit.CircuitColor.colorFromString(circuit[color]),
                    averageGrade: Grade(circuit[average_grade]))
            }.compactMap{$0}
        }
        catch {
            print (error)
            return []
        }
    }
}
