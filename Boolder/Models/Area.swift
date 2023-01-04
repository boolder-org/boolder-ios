//
//  Area.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 07/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import UIKit
import SQLite

struct Area : Identifiable {
    let id: Int
    let name: String
    let descriptionFr: String?
    let descriptionEn: String?
    let parkingShortName: String?
    let parkingUrl: String?
    let parkingDistance: Int?
    let level1: Bool
    let level2: Bool
    let level3: Bool
    let level4: Bool
    let level5: Bool
    let level6: Bool
    let level7: Bool
    let southWestLat: Double
    let southWestLon: Double
    let northEastLat: Double
    let northEastLon: Double
    
    static func load(id: Int) -> Area? {
        do {
            let db = SqliteStore.shared.db
            
            let areas = Table("areas").filter(Expression(literal: "id = '\(id)'"))
            
            let name = Expression<String>("name")
            let descriptionFr = Expression<String?>("description_fr")
            let descriptionEn = Expression<String?>("description_en")
            let parkingShortName = Expression<String?>("parking_short_name")
            let parkingUrl = Expression<String?>("parking_url")
            let parkingDistance = Expression<Int?>("parking_distance")
            let level1 = Expression<Int>("level1")
            let level2 = Expression<Int>("level2")
            let level3 = Expression<Int>("level3")
            let level4 = Expression<Int>("level4")
            let level5 = Expression<Int>("level5")
            let level6 = Expression<Int>("level6")
            let level7 = Expression<Int>("level7")
            let southWestLat = Expression<Double>("south_west_lat")
            let southWestLon = Expression<Double>("south_west_lon")
            let northEastLat = Expression<Double>("north_east_lat")
            let northEastLon = Expression<Double>("north_east_lon")
            
            do {
                if let a = try db.pluck(areas) {
                    return Area(id: id, name: a[name], descriptionFr: a[descriptionFr], descriptionEn: a[descriptionEn], parkingShortName: a[parkingShortName], parkingUrl: a[parkingUrl], parkingDistance: a[parkingDistance],
                                level1: a[level1] == 1, level2: a[level2] == 1, level3: a[level3] == 1, level4: a[level4] == 1, level5: a[level5] == 1, level6: a[level6] == 1, level7: a[level7] == 1,
                                southWestLat: a[southWestLat], southWestLon: a[southWestLon],
                                northEastLat: a[northEastLat], northEastLon: a[northEastLon])
                }
                
                return nil
            }
            catch {
                print (error)
                return nil
            }
        }
    }
    
    static var all: [AreaWithCount] {
        let db = SqliteStore.shared.db
        
//        let grade = Expression<String>("grade")
//        let popularity = Expression<String>("popularity")
        let id = Expression<Int>("id")
        let areaId = Expression<Int>("area_id")
        let areas = Table("areas")
        let problems = Table("problems")
        let query = Table("areas").select(areas[id], problems[id].count)
            .join(problems, on: areas[id] == problems[areaId])
            .group(areas[id])
            .order(problems[id].count.desc)
//            .order(grade.desc, popularity.desc)
        
        
        do {
            return try db.prepare(query).map { area in
                AreaWithCount(area: Area.load(id: area[id])!, problemsCount: area[problems[id].count])
            }
        }
        catch {
            print (error)
            return []
        }
    }
    
    var levels : [Int:Bool] {
        [
            1: level1,
            2: level2,
            3: level3,
            4: level4,
            5: level5,
            6: level6,
            7: level7,
        ]
    }

    var problems: [Problem] {
//        print("problems")
        let db = SqliteStore.shared.db
        
        let grade = Expression<String>("grade")
        let popularity = Expression<String>("popularity")
        let problems = Table("problems").filter(Expression(literal: "area_id = '\(id)'")).order(grade.desc, popularity.desc)
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
    
    var popularProblems: [Problem] {
//        print("popular problems")
        return problems.filter{$0.featured}
    }
    
    // TODO: improve performance
    var problemsCount: Int {
//        print("problems count")
        return problems.count
    }
    
    var circuits: [Circuit] {
//        print("circuits")
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
            .filter(problems[areaId] == self.id)
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

extension Area : Comparable {
    static func < (lhs: Area, rhs: Area) -> Bool {
        lhs.name < rhs.name
    }
}

extension Area : Hashable {
    static func == (lhs: Area, rhs: Area) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct AreaWithCount : Identifiable {
    var id: Int {
        area.id
    }
    
    let area: Area
    let problemsCount: Int
}
