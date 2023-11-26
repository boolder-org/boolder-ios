//
//  OfflineManager.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/11/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import Foundation

class OfflineManager {
    static let shared = OfflineManager()
    
    private var areas: Set<Int>
    
    private init() {
        self.areas = Set([1,4])
    }
}
