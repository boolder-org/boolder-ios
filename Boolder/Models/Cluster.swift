//
//  Cluster.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/06/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import UIKit
import SQLite

struct Cluster : Identifiable {
    let id: Int
    let name: String
    let priority: Int
}

// MARK: SQLite
extension Cluster {
    static let id = Expression<Int>("id")
    static let name = Expression<String>("name")
    static let priority = Expression<Int>("priority")
    
    static func load(id: Int) -> Cluster? {
        
        let query = Table("clusters").filter(self.id == id)
        
        do {
            if let c = try SqliteStore.shared.db.pluck(query) {
                
                return Cluster(id: id, name: c[name], priority: c[priority])
            }
            
            return nil
        }
        catch {
            print (error)
            return nil
        }
    }
    
//    var problems: [Problem] {
//        let problems = Table("problems")
//            .filter(Problem.areaId == id)
//            .order(Problem.grade.desc, Problem.popularity.desc)
//        
//        do {
//            return try SqliteStore.shared.db.prepare(problems).map { problem in
//                Problem.load(id: problem[Problem.id])
//            }.compactMap{$0}
//        }
//        catch {
//            print (error)
//            return []
//        }
//    }
}
