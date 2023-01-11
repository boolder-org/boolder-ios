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
    let warningFr: String?
    let warningEn: String?
    let tags: [String]
    let southWestLat: Double
    let southWestLon: Double
    let northEastLat: Double
    let northEastLon: Double
    let level1Count: Int
    let level2Count: Int
    let level3Count: Int
    let level4Count: Int
    let level5Count: Int
    let level6Count: Int
    let level7Count: Int
    let level8Count: Int
    let problemsCount: Int
    
    var beginnerFriendly: Bool {
        tags.contains("beginner_friendly")
    }
    
    var popular: Bool {
        tags.contains("popular")
    }
    
    var dryFast: Bool {
        tags.contains("dry_fast")
    }
}

// MARK: SQLite
extension Area {
    static let id = Expression<Int>("id")
    static let name = Expression<String>("name")
    static let descriptionFr = Expression<String?>("description_fr")
    static let descriptionEn = Expression<String?>("description_en")
    static let warningFr = Expression<String?>("warning_fr")
    static let warningEn = Expression<String?>("warning_en")
    static let tags = Expression<String?>("tags")
    static let southWestLat = Expression<Double>("south_west_lat")
    static let southWestLon = Expression<Double>("south_west_lon")
    static let northEastLat = Expression<Double>("north_east_lat")
    static let northEastLon = Expression<Double>("north_east_lon")
    static let level1Count = Expression<Int>("level1_count")
    static let level2Count = Expression<Int>("level2_count")
    static let level3Count = Expression<Int>("level3_count")
    static let level4Count = Expression<Int>("level4_count")
    static let level5Count = Expression<Int>("level5_count")
    static let level6Count = Expression<Int>("level6_count")
    static let level7Count = Expression<Int>("level7_count")
    static let level8Count = Expression<Int>("level8_count")
    static let problemsCount = Expression<Int>("problems_count")
    
    static func load(id: Int) -> Area? {
        
        let query = Table("areas").filter(self.id == id)
        
        do {
            if let a = try SqliteStore.shared.db.pluck(query) {
                return Area(id: id, name: a[name],
                            descriptionFr: a[descriptionFr], descriptionEn: a[descriptionEn],
                            warningFr: a[warningFr], warningEn: a[warningEn],
                            tags: a[tags]?.components(separatedBy: ",") ?? [], // TODO: handle new tags that don't have a translation
                            southWestLat: a[southWestLat], southWestLon: a[southWestLon],
                            northEastLat: a[northEastLat], northEastLon: a[northEastLon],
                            level1Count: a[level1Count], level2Count: a[level2Count], level3Count: a[level3Count], level4Count: a[level4Count],
                            level5Count: a[level5Count], level6Count: a[level6Count], level7Count: a[level7Count], level8Count: a[level8Count],
                            problemsCount: a[problemsCount]
                )
            }
            
            return nil
        }
        catch {
            print (error)
            return nil
        }
        
    }
    
    // TODO: no join needed
    static var all2: [Area] {
        let areas = Table("areas")
        let problems = Table("problems")
        
        let query = areas.select(areas[id], problems[id].count)
            .join(problems, on: areas[id] == problems[Problem.areaId])
            .group(areas[id])
            .order(problems[id].count.desc)
        
        do {
            return try SqliteStore.shared.db.prepare(query).map { area in
                Area.load(id: area[id])
            }.compactMap{$0}
        }
        catch {
            print (error)
            return []
        }
    }
    
    static var forBeginners : [AreaWithCount] {
        let areas = Table("areas")
        let problems = Table("problems")
        
        let query = Table("areas").select(areas[id], problems[id].count)
            .filter(problems[Problem.grade] >= "1a")
            .filter(problems[Problem.grade] < "4a")
            .join(problems, on: areas[id] == problems[Problem.areaId])
            .group(areas[id])
            .order(problems[id].count.desc) // this will not take precedence over the "sort by number of circuits" below, but still useful
        
        do {
            return try SqliteStore.shared.db.prepare(query).map { area in
                AreaWithCount(area: Area.load(id: area[id])!, problemsCount: area[problems[id].count])
            }
            .filter{$0.area.beginnerFriendly}
            .sorted {
                // this will act as the 1st sorting criteria, before the "sort by number of easy problems" above
                $0.area.circuits.filter{$0.beginnerFriendly}.count > $1.area.circuits.filter{$0.beginnerFriendly}.count
            }
        }
        catch {
            print (error)
            return []
        }
    }
    
    var problems: [Problem] {
        let problems = Table("problems")
            .filter(Problem.areaId == id)
            .order(Problem.grade.desc, Problem.popularity.desc)
        
        do {
            return try SqliteStore.shared.db.prepare(problems).map { problem in
                Problem.load(id: problem[Problem.id])
            }.compactMap{$0}
        }
        catch {
            print (error)
            return []
        }
    }
    
    var levels: [LevelCount] {
        [
            .init(name: "1", count: level1Count),
            .init(name: "2", count: level2Count),
            .init(name: "3", count: level3Count),
            .init(name: "4", count: level4Count),
            .init(name: "5", count: level5Count),
            .init(name: "6", count: level6Count),
            .init(name: "7", count: level7Count),
            .init(name: "8", count: level8Count),
        ]
    }
    
    func problemsCount(level: Int) -> Int {
        let problems = Table("problems")
            .filter(Problem.areaId == id)
            .filter(Problem.grade >= "\(level)a")
            .filter(Problem.grade < "\(level+1)a")
        
        do {
            return try SqliteStore.shared.db.scalar(problems.count)
        }
        catch {
            print (error)
            return 0
        }
    }
    
    var popularProblems: [Problem] {
        return problems.filter{$0.featured}
    }
    
    var circuits: [Circuit] {
        let circuits = Table("circuits")
        let problems = Table("problems")
        
        let query = circuits.select(circuits[Circuit.id], problems[Problem.id].count)
            .join(problems, on: circuits[Circuit.id] == problems[Problem.circuitId])
            .group(circuits[Circuit.id], having: problems[Problem.id].count >= 10)
            .filter(problems[Problem.areaId] == self.id)
            .order(Circuit.averageGrade.asc)

        do {
            return try SqliteStore.shared.db.prepare(query).map { circuit in
                Circuit.load(id: circuit[Circuit.id])
            }.compactMap{$0}
        }
        catch {
            print (error)
            return []
        }
    }
    
    var poiRoutes: [PoiRoute] {
        let poiRoutes = Table("poi_routes")
        
        let query = poiRoutes.filter(PoiRoute.areaId == self.id)
        
        do {
            return try SqliteStore.shared.db.prepare(query).map { poiRoute in
                PoiRoute.load(id: poiRoute[PoiRoute.id])
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

struct AreaWithLevelsCount : Identifiable {
    var id: Int {
        area.id
    }
    
    let area: Area
    let problemsCount: [LevelCount]
}

struct LevelCount : Identifiable {
    var id: Int {
        Int(name)!
    }
    
    let name: String
    let count: Int
}
