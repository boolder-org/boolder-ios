//
//  Filters.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 03/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

class Filters: ObservableObject {
    
    @Published var gradeCategories: [Int] = [] // empty means all grades
    @Published var steepness: [Steepness.SteepnessType] = Steepness.SteepnessType.allCases
    @Published var heightMax: Int = 6
    @Published var photoPresent = false
    @Published var circuit: Circuit.CircuitType? = nil
}
