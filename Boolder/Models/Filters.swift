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
    
    var gradeCategories = Set<Int>() // empty means all grades
    var steepness: Set<Steepness.SteepnessType> = Set(Steepness.SteepnessType.allCases)
    var heightMax: Int = 6
    var photoPresent = false
    var circuit: Circuit.CircuitType? = nil
}
