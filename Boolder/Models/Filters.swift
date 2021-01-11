//
//  Filters.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 03/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct Filters {
    var gradeRange: GradeRange? = nil
    var steepness: Set<Steepness> = Set()
    var heightMax = Int.max
    var photoPresent = false
    var circuit: Circuit.CircuitColor? = nil
    var favorite = false
    var ticked = false
    var risky = true
    var mapMakerModeEnabled = false
    
    func filtersCount() -> Int {
        let initialValues = Filters()
        var count = 0
        
        if gradeRange != initialValues.gradeRange { count += 1 }
        if circuit != initialValues.circuit { count += 1 }
        if steepness != initialValues.steepness { count += 1 }
        if heightMax != initialValues.heightMax { count += 1 }
        if photoPresent != initialValues.photoPresent { count += 1 }
        if favorite != initialValues.favorite { count += 1 }
        if ticked != initialValues.ticked { count += 1 }
        if risky != initialValues.risky { count += 1 }
        if mapMakerModeEnabled != initialValues.mapMakerModeEnabled { count += 1 }
        
        return count
    }
}
