//
//  Area.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 07/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import UIKit
import SQLite
import CoreLocation

typealias Expression = SQLite.Expression

struct Area : Identifiable {
    let id: Int
    let name: String
    let nameSearchable: String
    let priority: Int
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
    let clusterId: Int?
    let downloadSize: Double
    
    static var forBeginners : [Area] {
        all
            .filter{$0.beginnerFriendly}
            .sorted {
                $0.circuits.filter{$0.beginnerFriendly}.count > $1.circuits.filter{$0.beginnerFriendly}.count
            }
    }
    
    var popularProblems: [Problem] {
        problems.filter{$0.featured}
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
    
    var levels: [Level] {
        [
            .init(id: 1, count: level1Count),
            .init(id: 2, count: level2Count),
            .init(id: 3, count: level3Count),
            .init(id: 4, count: level4Count),
            .init(id: 5, count: level5Count),
            .init(id: 6, count: level6Count),
            .init(id: 7, count: level7Count),
            .init(id: 8, count: level8Count),
        ]
    }
    
    struct Level : Identifiable {
        var id: Int
        let count: Int
        
        var name: String {
            String(id)
        }
    }
    
    var cluster: Cluster? {
        if let clusterId = clusterId {
            return Cluster.load(id: clusterId)
        }
        
        return nil
    }
    
    // TODO: use actual center
    var center: CLLocation {
        CLLocation(
            latitude: (Double(southWestLat) + Double(northEastLat))/2,
            longitude: (Double(southWestLon) + Double(northEastLon))/2
        )
    }
}

// MARK: SQLite
extension Area {
    static let id = Expression<Int>("id")
    static let name = Expression<String>("name")
    static let nameSearchable = Expression<String>("name_searchable")
    static let priority = Expression<Int>("priority")
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
    static let clusterId = Expression<Int?>("cluster_id")
    static let downloadSize = Expression<Double>("download_size")
    
    static func load(id: Int) -> Area? {
        
        let query = Table("areas").filter(self.id == id)
        
        do {
            if let a = try SqliteStore.shared.db.pluck(query) {
                let allowedTags = ["popular", "beginner_friendly", "family_friendly", "dry_fast"]
                let tags = a[tags]?.components(separatedBy: ",").filter{allowedTags.contains($0)}
                
                return Area(id: id,
                            name: a[name],
                            nameSearchable: a[nameSearchable],
                            priority: a[priority],
                            descriptionFr: a[descriptionFr], descriptionEn: a[descriptionEn],
                            warningFr: a[warningFr], warningEn: a[warningEn],
                            tags: tags ?? [],
                            southWestLat: a[southWestLat], southWestLon: a[southWestLon],
                            northEastLat: a[northEastLat], northEastLon: a[northEastLon],
                            level1Count: a[level1Count], level2Count: a[level2Count], level3Count: a[level3Count], level4Count: a[level4Count],
                            level5Count: a[level5Count], level6Count: a[level6Count], level7Count: a[level7Count], level8Count: a[level8Count],
                            problemsCount: a[problemsCount], clusterId: a[clusterId], downloadSize: a[downloadSize]
                )
            }
            
            return nil
        }
        catch {
            print (error)
            return nil
        }
        
    }
    
    static var all: [Area] {
        let query = Table("areas").order(problemsCount.desc)
        
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
    
    static func search(_ text: String) -> [Area] {
        let query = Table("areas")
            .order(priority.asc)
            .filter(nameSearchable.like("%\(text.normalized)%"))
            .limit(10)
        
        do {
            return try SqliteStore.shared.db.prepare(query).map { a in
                Area.load(id: a[id])
            }.compactMap{$0}
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
    
    var topos: [Topo] {
        let lines = Table("lines")
        let problems = Table("problems")
        
        let query = lines
            .join(problems, on: lines[Line.problemId] == problems[Problem.id])
            .filter(Problem.areaId == id)
        
        do {
            let topos = try SqliteStore.shared.db.prepare(query).map { line in
                Topo(id: line[Line.topoId], areaId: id)
            }
            
            return Array(Set(topos)).sorted{$0.id < $1.id}
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
