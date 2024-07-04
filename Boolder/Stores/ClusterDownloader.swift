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
    
    var cancellables = [AnyCancellable]()
    
    init(cluster: Cluster) {
        self.cluster = cluster
        
        areas = cluster.areas.map { area in
            DownloadCenter.shared.areaDownloader(id: area.id)
        }
        
        // TODO: make this a little less hacky
        // https://stackoverflow.com/a/57302695
        self.areas.forEach { area in
//            let c = $0.objectWillChange.sink(receiveValue: { self.objectWillChange.send() })
            let c = area.$status.map{$0.isDownloading}.removeDuplicates().sink(receiveValue: { _ in self.objectWillChange.send() })
            self.cancellables.append(c)
        }
    }
    
    var downloading: Bool {
//        print("downloading called")
//        print(areas.map{$0.areaId})
//        print(areas.map{$0.status.label})
        return areas.contains(where: {
            $0.isDownloading
        })
    }
}
