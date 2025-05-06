//
//  Boulder.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/04/2025.
//  Copyright © 2025 Nicolas Mondollot. All rights reserved.
//

struct Boulder {
    let id: Int
    
    var topos: [Topo] {
        Topo.onBoulder(id)
    }
    
    var starts: [Problem] {
        topos.flatMap{$0.starts}
    }
    
    func next(after: Problem) -> Problem? {
        if let index = starts.firstIndex(of: after.start) {
            return starts[(index + 1) % starts.count]
        }
        
        return nil
    }
    
    func previous(before: Problem) -> Problem? {
        if let index = starts.firstIndex(of: before.start) {
            return starts[(index + starts.count - 1) % starts.count]
        }
        
        return nil
    }
}
