//
//  GradeRange.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 06/11/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import Foundation

struct GradeRange : Equatable, Hashable {
    let min: Grade
    let max: Grade
    
    static let beginner =       GradeRange(min: Grade("1a"), max: Grade("3c+"))
    static let intermediate =   GradeRange(min: Grade("4a"), max: Grade("5c+"))
    static let advanced =       GradeRange(min: Grade("6a"), max: Grade("8c+"))

    
    // FIXME: rename localizedName
    var name: String {
        if self == Self.beginner {
            return NSLocalizedString("filters.grade.range.beginner", comment: "")
        }
        else if self == Self.intermediate {
            return NSLocalizedString("filters.grade.range.intermediate", comment: "")
        }
        else if self == Self.advanced {
            return NSLocalizedString("filters.grade.range.advanced", comment: "")
        }
        else {
            return "Personnalisé"
        }
    }
    
    var description: String {
        if self == Self.beginner {
            return NSLocalizedString("filters.grade.range.description.beginner", comment: "")
        }
        else if self == Self.intermediate {
            return NSLocalizedString("filters.grade.range.description.intermediate", comment: "")
        }
        else if self == Self.advanced {
            return NSLocalizedString("filters.grade.range.description.advanced", comment: "")
        }
        else {
            return "De \(min.string) à \(max.string)"
        }
    }
    
    var isCustom: Bool {
        self != .beginner && self != .intermediate && self != .advanced && !(min == Grade.min && max == Grade.max)
    }
    
    func contains(_ grade: Grade) -> Bool {
        grade >= self.min && grade <= self.max
    }

}
