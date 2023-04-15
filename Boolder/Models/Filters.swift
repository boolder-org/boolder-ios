//
//  Filters.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 03/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

struct Filters {
    var gradeRange: GradeRange? = nil
    var steepness: Set<Steepness> = Set()
    var popular = false
    var favorite = false
//    var ticked = false
    
    func filtersCount() -> Int {
        let initialValues = Filters()
        var count = 0
        
        if gradeRange != initialValues.gradeRange { count += 1 }
        if steepness != initialValues.steepness { count += 1 }
        if popular != initialValues.popular { count += 1 }
        if favorite != initialValues.favorite { count += 1 }
//        if ticked != initialValues.ticked { count += 1 }
        
        return count
    }
}
