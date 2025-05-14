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
    
    func nextTopo(after: Topo) -> Topo? {
        if let index = topos.firstIndex(of: after) {
            return topos[(index + 1) % topos.count]
        }
        
        return nil
    }
    
    func previousTopo(before: Topo) -> Topo? {
        if let index = topos.firstIndex(of: before) {
            return topos[(index + topos.count - 1) % topos.count]
        }
        
        return nil
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
