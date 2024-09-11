//
//  TopoWithPosition.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 11/09/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import Foundation
import UIKit
import SQLite

struct TopoWithPosition: Hashable, Identifiable {
    let id: Int
    let boulderId: Int?
    let position: Int?
    
    var topo: Topo {
        Topo(id: id, areaId: 14)
    }
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
    
    var onSameBoulder: [TopoWithPosition] {
        guard let boulderId = boulderId else { return [] }
        
        return TopoWithPosition.onBoulder(boulderId)
    }
    
    static func onBoulder(_ id: Int) -> [TopoWithPosition] {
        let query = Table("topos")
            .filter(TopoWithPosition.boulderId == id)
            .order(TopoWithPosition.position)
        
        do {
            return try SqliteStore.shared.db.prepare(query).map { topo in
                TopoWithPosition(id: topo[TopoWithPosition.id], boulderId: topo[TopoWithPosition.boulderId], position: topo[TopoWithPosition.position])
            }
        }
        catch {
            print (error)
            return []
        }
    }
    
    var next: TopoWithPosition? {
        if let index = onSameBoulder.firstIndex(of: self) {
            return onSameBoulder[(index + 1) % onSameBoulder.count]
        }
        
        return nil
    }
}
