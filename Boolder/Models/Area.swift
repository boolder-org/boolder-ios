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
    
    // FIXME: don't use AreaView
    var levelsCount : [AreaView.Level] {
        [
            .init(name: "1", count: min(150, problemsCount(level: 1))),
            .init(name: "2", count: min(150, problemsCount(level: 2))),
            .init(name: "3", count: min(150, problemsCount(level: 3))),
            .init(name: "4", count: min(150, problemsCount(level: 4))),
            .init(name: "5", count: min(150, problemsCount(level: 5))),
            .init(name: "6", count: min(150, problemsCount(level: 6))),
            .init(name: "7", count: min(150, problemsCount(level: 7))),
            .init(name: "8", count: min(150, problemsCount(level: 8))),
        ]
    }
    
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
    
    static func load(id: Int) -> Area? {
        
        let query = Table("areas").filter(self.id == id)
        
        do {
            if let a = try SqliteStore.shared.db.pluck(query) {
                return Area(id: id, name: a[name],
                            descriptionFr: a[descriptionFr], descriptionEn: a[descriptionEn],
                            warningFr: a[warningFr], warningEn: a[warningEn],
                            tags: a[tags]?.components(separatedBy: ",") ?? [], // TODO: handle new tags that don't have a translation
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
    
    static var all: [AreaWithCount] {
        let areas = Table("areas")
        let problems = Table("problems")
        
        let query = areas.select(areas[id], problems[id].count)
            .join(problems, on: areas[id] == problems[Problem.areaId])
            .group(areas[id])
            .order(problems[id].count.desc)
        
        do {
            return try SqliteStore.shared.db.prepare(query).map { area in
                AreaWithCount(area: Area.load(id: area[id])!, problemsCount: area[problems[id].count])
            }
        }
        catch {
            print (error)
            return []
        }
    }
    
    static func allWithLevel(_ level: Int) -> [AreaWithCount] {
        let areas = Table("areas")
        let problems = Table("problems")
        
        let query = Table("areas").select(areas[id], problems[id].count)
            .filter(problems[Problem.grade] >= "\(level)a")
            .filter(problems[Problem.grade] < "\(level+1)a")
            .join(problems, on: areas[id] == problems[Problem.areaId])
            .group(areas[id])
            .order(problems[id].count.desc)
        
        do {
            return try SqliteStore.shared.db.prepare(query).map { area in
                AreaWithCount(area: Area.load(id: area[id])!, problemsCount: area[problems[id].count])
            }
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
            .order(problems[id].count.desc)
        
        do {
            return try SqliteStore.shared.db.prepare(query).map { area in
                AreaWithCount(area: Area.load(id: area[id])!, problemsCount: area[problems[id].count])
            }
            .filter{$0.area.beginnerFriendly}
            .sorted {
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
    
    // TODO: improve performance
    var problemsCount: Int {
        return problems.count
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
    let id = UUID()
    
    let name: String
    let count: Int
}
