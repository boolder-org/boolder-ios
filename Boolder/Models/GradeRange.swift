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
