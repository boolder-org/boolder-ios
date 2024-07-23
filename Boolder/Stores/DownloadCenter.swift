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
    
    // TODO: move to AreaDownloader initializer?
    func start() {
        allAreas.forEach { areaDownloader in
            areaDownloader.updateStatus()
        }
    }
    
    func areaDownloader(id: Int) -> AreaDownloader {
        allAreas.first { areaDownloader in
            areaDownloader.id == id
        }! // FIXME: use a dedicated error 
    }
}


