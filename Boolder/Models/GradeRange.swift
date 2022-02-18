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

    
    var localizedName: String {
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
            return NSLocalizedString("filters.grade.range.custom", comment: "")
        }
    }
    
    var description: String {
       "\(min.string) → \(max.advanced(by: -1).string)"
    }
    
    var isCustom: Bool {
        self != .beginner && self != .intermediate && self != .advanced
    }
    
    func contains(_ grade: Grade) -> Bool {
        grade >= self.min && grade <= self.max
    }

}
