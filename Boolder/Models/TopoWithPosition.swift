//
//  TopoWithPosition.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 11/09/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import Foundation
import SQLite

struct TopoWithPosition: Hashable {
    let id: Int
    let boulderId: Int?
    let position: Int?
}

// MARK: SQLite
extension TopoWithPosition {
    static let id = Expression<Int>("id")
    static let boulderId = Expression<Int>("boulder_id")
    static let position = Expression<Int>("position")
    
    static func load(id: Int) -> TopoWithPosition? {
        do {
            let query = Table("topos").filter(self.id == id)
            
            do {
                if let t = try SqliteStore.shared.db.pluck(query) {
                    return TopoWithPosition(id: t[self.id], boulderId: t[boulderId], position: t[position])
                }
                
                return nil
            }
            catch {
                print (error)
                return nil
            }
        }
    }
}
