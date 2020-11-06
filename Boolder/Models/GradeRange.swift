//
//  GradeRange.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 06/11/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import Foundation

enum GradeRange: CaseIterable, Comparable {
    case beginner
    case intermediate
    case advanced
    
    var name: String {
        switch self {
        case .beginner:
            return NSLocalizedString("filters.grade.range.beginner", comment: "")
        case .intermediate:
            return NSLocalizedString("filters.grade.range.intermediate", comment: "")
        case .advanced:
            return NSLocalizedString("filters.grade.range.advanced", comment: "")
        }
    }
    
    var description: String {
        switch self {
        case .beginner:
            return NSLocalizedString("filters.grade.range.description.beginner", comment: "")
        case .intermediate:
            return NSLocalizedString("filters.grade.range.description.intermediate", comment: "")
        case .advanced:
            return NSLocalizedString("filters.grade.range.description.advanced", comment: "")
        }
    }
    
    var grades: Set<Grade> {
        switch self {
        case .beginner:
            return Set(Grade("1a")..<Grade("4a"))
        case .intermediate:
            return Set(Grade("4a")..<Grade("6a"))
        case .advanced:
            return Set(Grade("6a")..<Grade.max)
        }
    }
}
