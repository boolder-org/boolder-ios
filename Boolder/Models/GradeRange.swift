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
    
    static let level1 =       GradeRange(min: Grade("1a"), max: Grade("1c+"))
    static let level2 =       GradeRange(min: Grade("2a"), max: Grade("2c+"))
    static let level3 =       GradeRange(min: Grade("3a"), max: Grade("3c+"))
    static let level4 =       GradeRange(min: Grade("4a"), max: Grade("4c+"))
    static let level5 =       GradeRange(min: Grade("5a"), max: Grade("5c+"))
    static let level6 =       GradeRange(min: Grade("6a"), max: Grade("6c+"))
    static let level7 =       GradeRange(min: Grade("7a"), max: Grade("7c+"))
    static let level8 =       GradeRange(min: Grade("8a"), max: Grade("8c+"))
    static let level9 =       GradeRange(min: Grade("9a"), max: Grade("9c+"))
    
    static func level(_ level: Int) -> GradeRange {
        switch level {
        case 1:
            return .level1
        case 2:
            return .level2
        case 3:
            return .level3
        case 4:
            return .level4
        case 5:
            return .level5
        case 6:
            return .level6
        case 7:
            return .level7
        case 8:
            return .level8
        case 9:
            return .level9
        default:
            return .level1 // FIXME
        }
    }

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
