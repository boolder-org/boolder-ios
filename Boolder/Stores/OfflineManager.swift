//
//  OfflineManager.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/11/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import Foundation

class OfflineManager: ObservableObject {
    static let shared = OfflineManager()
    
    @Published var offlineAreas = [OfflineArea]()
    
    
    private init() {
        offlineAreas = Area.all.sorted{
            $0.name.folding(options: .diacriticInsensitive, locale: .current) < $1.name.folding(options: .diacriticInsensitive, locale: .current)
        }.map { area in
            OfflineArea(areaId: area.id, downloaded: false)
        }
    }
}

struct OfflineArea: Identifiable {
    let areaId: Int
    var downloaded: Bool
    
//        init(areaId: Int, downloaded: Bool) {
//            self.areaId = areaId
//            self.downloaded = downloaded
//        }
    
    var id: Int {
        areaId
    }
    
    var area: Area {
        Area.load(id: areaId)!
    }
    
    mutating func download() {
        downloaded = true
    }
}
