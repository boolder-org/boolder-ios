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
    static let level1 =         GradeRange(min: Grade("1a"), max: Grade("1c+"))
    static let level2 =         GradeRange(min: Grade("2a"), max: Grade("2c+"))
    static let level3 =         GradeRange(min: Grade("3a"), max: Grade("3c+"))
    static let level4 =         GradeRange(min: Grade("4a"), max: Grade("4c+"))
    static let level5 =         GradeRange(min: Grade("5a"), max: Grade("5c+"))
    static let level6 =         GradeRange(min: Grade("6a"), max: Grade("6c+"))
    static let level7 =         GradeRange(min: Grade("7a"), max: Grade("7c+"))
    static let level8 =         GradeRange(min: Grade("8a"), max: Grade("8c+"))

    var description: String {
        if self == Self.beginner {
            return NSLocalizedString("filters.grade.range.beginner", comment: "")
        }
        else if self == Self.level4 {
            return NSLocalizedString("filters.grade.range.level4", comment: "")
        }
        else if self == Self.level5 {
            return NSLocalizedString("filters.grade.range.level5", comment: "")
        }
        else if self == Self.level6 {
            return NSLocalizedString("filters.grade.range.level6", comment: "")
        }
        else if self == Self.level7 {
            return NSLocalizedString("filters.grade.range.level7", comment: "")
        }
        else if self == Self.level8 {
            return NSLocalizedString("filters.grade.range.level8", comment: "")
        }
        else {
            return "\(min.string) → \(max.advanced(by: -1).string)"
        }
    }
        
    var isCustom: Bool {
        self != .beginner && self != .level4 && self != .level5 && self != .level6 && self != .level7 && self != .level8
    }
}
