//
//  DiscoverViewModel.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 03/01/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import SQLite
import SwiftUI

struct AreaWithCount : Identifiable {
    var id: Int {
        area.id
    }
    
    let area: Area
    let problemsCount: Int
}

class DiscoverViewModel : ObservableObject {
    
    
    
    var areas: [AreaWithCount] {
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
}
