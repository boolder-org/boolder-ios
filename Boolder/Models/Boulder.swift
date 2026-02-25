//
//  Boulder.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 07/02/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

struct Boulder {
    let id: Int
    
    var topos: [Topo] {
        Topo.onBoulder(id)
    }
    
    var problems: [Problem] {
        topos.flatMap { $0.problems }
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
}
