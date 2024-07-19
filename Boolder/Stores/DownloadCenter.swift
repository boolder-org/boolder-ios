//
//  OfflineManager.swift
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
    @Published var requestedAreas = [AreaDownloader]()
    
    let settings = DownloadSettings.shared
    var cancellable: Cancellable?
    
    private init() {
        allAreas = Area.all.sorted{
            $0.name.folding(options: .diacriticInsensitive, locale: .current) < $1.name.folding(options: .diacriticInsensitive, locale: .current)
        }.map { area in
            AreaDownloader(areaId: area.id)
        }
        
        cancellable = settings.$areaIds
            .map { ids in ids.map{ id in Area.load(id: id)}.compactMap{$0} }
            .map { $0.map{self.areaDownloader(id: $0.id)} }
            .assign(to: \.requestedAreas, on: self)
    }
    
    func start() {
        requestedAreas.forEach { areaDownloader in
            areaDownloader.updateStatus()
        }
    }
    
    func areaDownloader(id: Int) -> AreaDownloader {
        allAreas.first { areaDownloader in
            areaDownloader.id == id
        }! // FIXME: use a dedicated error
    }
}


