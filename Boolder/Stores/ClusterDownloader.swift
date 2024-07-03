//
//  ClusterDownloader.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 03/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import Foundation
import Combine

class ClusterDownloader: ObservableObject {
    
    private let cluster: Cluster
    @Published var areas = [AreaDownloader]()
    @Published var downloading: Bool = false
    
    let settings = DownloadSettings.shared
    var cancellable: Cancellable?
    
    init(cluster: Cluster) {
        self.cluster = cluster
        
        areas = cluster.areas.map { area in
            AreaDownloader(areaId: area.id, status: settings.areaIds.contains(area.id) ? .requested : .initial)
        }
        
        cancellable = $areas
            .map { objects in
                objects.map { $0.$status }
            }
            .flatMap { statuses in
                Publishers.MergeMany(statuses)
            }
            .map { status in
                self.areas.contains(where: { $0.status == .initial })
            }
            .removeDuplicates()
            .assign(to: \.downloading, on: self)
        
//        cancellable = settings.$areaIds
//            .map { $0.map{self.areaDownloader(id: $0)} }
//            .assign(to: \.requestedAreas, on: self)
    }
    
    func areaDownloader(id: Int) -> AreaDownloader {
        areas.first { areaDownloader in
            areaDownloader.id == id
        }! // FIXME: use a dedicated error
    }
}
