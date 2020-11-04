//
//  GradeFilter.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 03/11/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import Foundation

struct GradeFilter {
    enum Category: CaseIterable {
        case kid
        case beginner
        case intermediate
        case advanced
        
        var name: String {
            switch self {
            case .kid:
                return NSLocalizedString("grade.category.kid", comment: "")
            case .beginner:
                return NSLocalizedString("grade.category.beginner", comment: "")
            case .intermediate:
                return NSLocalizedString("grade.category.intermediate", comment: "")
            case .advanced:
                return NSLocalizedString("grade.category.advanced", comment: "")
            }
        }
        
        var grades: Set<Grade> {
            switch self {
            case .kid:
                return Set(Grade("1a")..<Grade("2a"))
            case .beginner:
                return Set(Grade("2a")..<Grade("4a"))
            case .intermediate:
                return Set(Grade("4a")..<Grade("6a"))
            case .advanced:
                return Set(Grade("6a")..<Grade.max)
            }
        }
    }
    
    static let allCategories: Array<Category> = [.kid, .beginner, .intermediate, .advanced]
    
    var categories: Set<Category>
    
    init(_ categories: Set<Category>) {
        self.categories = categories
    }
}
