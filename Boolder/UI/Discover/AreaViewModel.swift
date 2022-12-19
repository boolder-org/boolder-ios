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
    
    init(area: Area) {
        self.area = area
    }
    
    var problems: [Problem] {
        let db = SqliteStore.shared.db
        
        let grade = Expression<String>("grade")
        let problems = Table("problems").filter(Expression(literal: "area_id = '\(area.id)'")).order(grade.desc)
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
}
