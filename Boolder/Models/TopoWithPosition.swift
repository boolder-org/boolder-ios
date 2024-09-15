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
    
    // FIXME: merge Topo and TopoWithPosition
    var topo: Topo {
        Topo(id: id, areaId: problems.first?.areaId ?? 14)
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
    
    var problems: [Problem] {
        let query = Table("lines")
            .filter(Line.topoId == id)

        do {
            let lines = try SqliteStore.shared.db.prepare(query).map { l in
                Problem.load(id: l[Line.problemId])
            }
            
            return lines.compactMap{$0}
                .filter { $0.topoId == self.id } // to avoid showing multi-lines problems (eg. traverses) that don't actually *start* on the same topo
                .filter { $0.line?.coordinates != nil }
        }
        catch {
            print (error)
            return []
        }
    }
    
    var firstProblemOnTheLeft: Problem? {
        problems.sorted { ($0.lineFirstPoint?.x ?? 1.0) < ($1.lineFirstPoint?.x ?? 1.0) }.first
    }
    
    var firstProblemOnTheRight: Problem? {
        problems.sorted { ($0.lineFirstPoint?.x ?? 0) > ($1.lineFirstPoint?.x ?? 0) }.first
    }
    
    // TODO: move to Topo
    var startGroups: [StartGroup] {
        var groups = [StartGroup]()
        
        problems.forEach { p in
            let group = groups.first{$0.overlaps(with: p)}
            
            if let group = group {
                group.addProblem(p)
            }
            else {
                groups.append(StartGroup(problem: p))
            }
        }
        
        return groups
    }
}
