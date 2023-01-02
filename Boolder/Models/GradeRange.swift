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
//    static let intermediate =   GradeRange(min: Grade("4a"), max: Grade("5c+"))
    static let level4 =         GradeRange(min: Grade("4a"), max: Grade("4c+"))
    static let level5 =         GradeRange(min: Grade("5a"), max: Grade("5c+"))
    static let level6 =         GradeRange(min: Grade("6a"), max: Grade("6c+"))
    static let level7 =         GradeRange(min: Grade("7a"), max: Grade("7c+"))
    static let level8 =         GradeRange(min: Grade("8a"), max: Grade("8c+"))

    var localizedName: String {
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
            return NSLocalizedString("filters.grade.range.custom", comment: "")
        }
    }
    
    var description: String {
        if self == Self.beginner {
            return "1 → 3"
        }
        else if self == Self.level4 {
            return "4"
        }
        else if self == Self.level5 {
            return "5"
        }
        else if self == Self.level6 {
            return "6"
        }
        else if self == Self.level7 {
            return "7"
        }
        else if self == Self.level8 {
            return "8"
        }
        else {
            return "\(min.string) → \(max.advanced(by: -1).string)"
        }
    }
    
    var isCustom: Bool {
        self != .beginner && self != .level4 && self != .level5 && self != .level6 && self != .level7 && self != .level8
    }
    
    func contains(_ grade: Grade) -> Bool {
        grade >= self.min && grade <= self.max
    }
    
    func contains(_ range: GradeRange) -> Bool {
        range.min >= self.min && range.max <= self.max
    }

    func concatenate(with other: GradeRange?) -> GradeRange {
        if let other = other {
            return GradeRange(min: Swift.min(self.min, other.min), max: Swift.max(self.max, other.max))
        }
        else {
            return self
        }
    }
    
    func remove(_ other: GradeRange?) -> GradeRange? {
        // TODO: handle case when other is larger than self
        // TODO: handle case when range is not a level
        if let other = other {
            if other == self {
                return nil
            }
            if other.min == self.min {
                return GradeRange(min: other.max.advanced(by: 1), max: self.max)
            }
            else if other.max == self.max {
                return GradeRange(min: self.min, max: other.min.advanced(by: -1))
            }
            else {
                return self
            }
        }
        else {
            return self
        }
    }
}
