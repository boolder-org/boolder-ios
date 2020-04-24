//
//  Topo.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 19/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import UIKit

struct Topo: Decodable {
    let id: Int
    let line: [PhotoPercentCoordinate]?
    
    struct PhotoPercentCoordinate: Decodable {
        let x: Double
        let y: Double
    }
    
    func photo() -> UIImage? {
        UIImage(named: "topo-\(String(id)).jpg")
    }
}
