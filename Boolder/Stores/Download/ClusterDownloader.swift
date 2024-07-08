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
            let c = area.objectWillChange.sink(receiveValue: { self.objectWillChange.send() })
//            let c = area.$status.map{$0.downloading}.removeDuplicates().sink(receiveValue: { _ in self.objectWillChange.send() })
            self.cancellables.append(c)
        }
    }
    
    var progress: Double {
        let base = areas.filter { $0.status != .initial }
        
        let values = base.map{$0.status.progress}
        let weights = base.map{$0.area.downloadSize}
//        let downloading = total.map{$0.status.progress}.reduce(0) { sum, progress in sum + progress }.rounded()
        
        print(values)
        print(weights)
        
        let p = weightedAverage(values: values, weights: weights) ?? 0.5
        print(p)
        
        return p
    }
    
    func weightedAverage(values: [Double], weights: [Double]) -> Double? {
        // Check if both arrays have the same length
        guard values.count == weights.count else {
            print("The number of values and weights must be the same.")
            return nil
        }

        // Check if weights are not empty
        guard !weights.isEmpty else {
            print("Weights array must not be empty.")
            return nil
        }
        
        // Calculate the sum of weighted values
        let weightedSum = zip(values, weights).map(*).reduce(0, +)
        
        // Calculate the sum of weights
        let totalWeight = weights.reduce(0, +)
        
        // Ensure the total weight is not zero to avoid division by zero
        guard totalWeight != 0 else {
            print("Total weight must not be zero.")
            return nil
        }
        
        // Calculate the weighted average
        let weightedAverage = weightedSum / totalWeight
        
        return weightedAverage
    }
    
    var downloading: Bool {
//        print("downloading called")
//        print(areas.map{$0.areaId})
//        print(areas.map{$0.status.label})
        return areas.contains(where: {
            $0.downloading
        })
    }
    
    var severalDownloading: Bool {
        return areas.filter { $0.downloading }.count >= 2
    }
    
    func stopDownloads() {
        areas.filter { $0.status != .initial }.forEach{ $0.cancel() }
    }
    
    var allDownloaded: Bool {
        areas.allSatisfy { $0.status == .downloaded }
    }
    
//    var remainingToDownload: Int {
//        areas.count - areas.filter{ $0.status == .downloaded }.count
//    }
    
    var downloadRequested: Bool {
        areas.filter { $0.status != .initial }.count > 0
    }
    
    var totalSize : Double {
        remainingAreasToDownload.map { $0.area.downloadSize }.reduce(0) { sum, size in
            sum + size
        }.rounded()
    }
    
    var remainingAreasToDownload: [AreaDownloader] {
        self.areas
            .filter { $0.status != .downloaded }
    }
}
