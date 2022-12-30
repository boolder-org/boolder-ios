//
//  AreaViewModel.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 19/12/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SQLite
import SwiftUI

class AreaViewModel : ObservableObject {
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
        let problems = Table("problems").filter(Expression(literal: "area_id = '\(area.id)'")).order(grade.desc, popularity.desc)
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
    
    // TODO: improve performance
    var problemsCount: Int {
        problems.count
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
        let circuitId = Expression<Int>("circuit_id")
        let areaId = Expression<Int>("area_id")
        let averageGrade = Expression<String>("average_grade")
        let beginnerFriendly = Expression<Int>("beginner_friendly")
        let dangerous = Expression<Int>("dangerous")
        let southWestLat = Expression<Double>("south_west_lat")
        let southWestLon = Expression<Double>("south_west_lon")
        let northEastLat = Expression<Double>("north_east_lat")
        let northEastLon = Expression<Double>("north_east_lon")
        let circuits = Table("circuits")
        let problems = Table("problems")
        let color = Expression<String>("color")
        
        let query = circuits.select(circuits[id], circuits[color], circuits[averageGrade], circuits[beginnerFriendly], circuits[dangerous],
                                    circuits[southWestLat], circuits[southWestLon], circuits[northEastLat], circuits[northEastLon],
                                    problems[id].count)
            .join(problems, on: circuits[id] == problems[circuitId])
            .group(circuits[id], having: problems[id].count >= 10)
            .filter(problems[areaId] == area.id)
            .order(averageGrade.asc)
        
//        print(query.asSQL())

        do {
            return try db.prepare(query).map { circuit in
                Circuit(
                    id: circuit[id],
                    color: Circuit.CircuitColor.colorFromString(circuit[color]),
                    averageGrade: Grade(circuit[averageGrade]),
                    beginnerFriendly: circuit[beginnerFriendly] == 1,
                    dangerous: circuit[dangerous] == 1,
                    southWestLat: circuit[southWestLat], southWestLon: circuit[southWestLon], northEastLat: circuit[northEastLat], northEastLon: circuit[northEastLon])
//                Circuit(
//                    id: circuit[id],
//                    color: Circuit.CircuitColor.colorFromString(circuit[color]),
//                    averageGrade: Grade(circuit[average_grade]),
//                )
            }.compactMap{$0}
        }
        catch {
            print (error)
            return []
        }
    }
}
