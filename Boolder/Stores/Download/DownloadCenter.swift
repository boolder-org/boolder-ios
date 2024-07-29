//
//  DownloadCenter.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/11/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import Foundation
import Combine

class DownloadCenter: ObservableObject {
    static let shared = DownloadCenter()
    
    private var allAreas = [AreaDownloader]()
    
    private init() {
        allAreas = Area.all.sorted{
            $0.name.folding(options: .diacriticInsensitive, locale: .current) < $1.name.folding(options: .diacriticInsensitive, locale: .current)
        }.map { area in
            AreaDownloader(areaId: area.id)
        }
    }
    
    func start() {
        allAreas.forEach { $0.loadStatus() }
    }
    
    func areaDownloader(id: Int) -> AreaDownloader {
        allAreas.first { $0.id == id }! // Careful when changing this method, you need to make sure the id exists in the allAreas array
    }
    
    // Careful: use only in dev environment
    func forceReset() {
        #if DEVELOPMENT
        allAreas.forEach { $0.remove() }
        #endif
    }
}


