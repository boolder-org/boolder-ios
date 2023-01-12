//
//  Grade.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 30/03/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

struct Grade: Hashable, CustomStringConvertible {
    let string: String
    
    static let grades = ["1a", "1a+", "1b", "1b+", "1c", "1c+", "2a", "2a+", "2b", "2b+", "2c", "2c+", "3a", "3a+", "3b", "3b+", "3c", "3c+", "4a", "4a+", "4b", "4b+", "4c", "4c+", "5a", "5a+", "5b", "5b+", "5c", "5c+", "6a", "6a+", "6b", "6b+", "6c", "6c+", "7a", "7a+", "7b", "7b+", "7c", "7c+", "8a", "8a+", "8b", "8b+", "8c", "8c+", "9a", "9a+", "9b", "9b+", "9c", "9c+"]
    
    static let min = Grade(Self.grades.first!)
    static let max = Grade(Self.grades.last!)
    
    static let visibleGrades = ["1a", "1b", "1c", "2a", "2b", "2c", "3a", "3b", "3c", "4a", "4b", "4c", "5a", "5b", "5c", "6a", "6b", "6c", "7a", "7b", "7c", "8a", "8b", "8c", "9a"]
    
    init(_ string: String) {
        let lowercased = string.lowercased()
        
        // TODO: is this a reasonable default?
        if Self.grades.firstIndex(of: lowercased) == nil {
            self.string = Self.grades.first!
        }
        else {
            self.string = lowercased
        }
    }
    
    init(index: Int) {
        string = Self.grades[index % Grade.grades.count]
    }
    
    func category() -> Int {
        Int(String(string.first!))!
    }
    
    var description: String {
        return string
    }
}

extension Grade: Comparable {
    
    func index() -> Int {
        Self.grades.firstIndex(of: string)!
    }
    
    static func < (lhs: Grade, rhs: Grade) -> Bool {
        return lhs.index() < rhs.index()
    }
    
    static func == (lhs: Grade, rhs: Grade) -> Bool {
        return lhs.string == rhs.string
    }
}

extension Grade: Strideable {
    public func distance(to other: Grade) -> Grade.Stride {
        return Stride(other.index()) - Stride(index())
    }

    public func advanced(by n: Grade.Stride) -> Grade {
        let newIndex = Stride(index() + n)
        return Grade(index: newIndex)
    }

    public typealias Stride = Int
}
