//
//  Filters.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 03/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct Filters {
    static let allGradeCategories = [1,2,3,4,5,6,7,8]
    
    var gradeCategories = Set(Self.allGradeCategories)
    var steepness: Set<Steepness.SteepnessType> = Set(Steepness.SteepnessType.allCases)
    var heightMax = Int.max
    var photoPresent = false
    var circuit: Circuit.CircuitType? = nil
    var favorite = false
    var ticked = false
    var risky = true
    
    func filtersCount() -> Int {
        let initialValues = Filters()
        var count = 0
        
        if gradeCategories != initialValues.gradeCategories { count += 1 }
        if steepness != initialValues.steepness { count += 1 }
        if heightMax != initialValues.heightMax { count += 1 }
        if photoPresent != initialValues.photoPresent { count += 1 }
        if favorite != initialValues.favorite { count += 1 }
        if ticked != initialValues.ticked { count += 1 }
        if risky != initialValues.risky { count += 1 }
        
        return count
    }
}
