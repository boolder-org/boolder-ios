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
    
    private var downloadQueue = [AreaDownloader]()
    private var currentIndex = 0
    @Published var currentDownloader: AreaDownloader?
    
    var cancellables = [AnyCancellable]()
    
    init(cluster: Cluster) {
        self.cluster = cluster
        
        areas = cluster.areas.map { area in
            DownloadCenter.shared.areaDownloader(id: area.id)
        }
        
        // hack to make sure we publish changes when any of the AreaDownloader publishes a change
        // inspired by https://stackoverflow.com/a/57302695
        self.areas.forEach { area in
            let c = area.objectWillChange
                .debounce(for: .milliseconds(500), scheduler: RunLoop.main) // to avoid refreshing ClusterView too often, which makes the UI unresponsive
                .sink(receiveValue: { self.objectWillChange.send() })
            self.cancellables.append(c)
        }
    }
    
//    func addToQueue() {
//    }
    
    func start() {
        remainingAreasToDownload.forEach{ $0.queue() }
        downloadQueue = Array(remainingAreasToDownload) // TODO: sort
        
        guard !downloadQueue.isEmpty else { return }
        currentIndex = 0
        startNextDownload()
    }
    
    private func startNextDownload() {
        guard currentIndex < downloadQueue.count else { return }
        let downloader = downloadQueue[currentIndex]
        currentDownloader = downloader
        
        downloader.start(onSuccess: { [self] in
            self.currentIndex += 1
            self.startNextDownload()
            
            }, onFailure: { [self] in
               stopDownloads()
            })
    }
    
    func stopDownloads() {
        areas.filter{ $0.status.downloadingOrQueued }.forEach{ $0.cancel() }
        
//        currentDownloader?.cancel()
        downloadQueue = []
    }
    
    func removeDownloads() {
        areas.forEach { $0.remove() }
    }
    
    var downloadingOrQueued: Bool {
        areas.contains{ $0.downloadingOrQueued }
    }
    
    var allDownloaded: Bool {
        areas.allSatisfy{ $0.status == .downloaded }
    }
    
    var downloadRequested: Bool {
        areas.filter{ $0.status != .initial }.count > 0
    }
    
    var totalSize : Double {
        remainingAreasToDownload.map { $0.area.downloadSize }.reduce(0,+)
    }
    
    var remainingAreasToDownload: [AreaDownloader] {
        self.areas.filter { $0.status != .downloaded }
    }
    
    var progress: Double {
        let base = areas.filter { $0.status != .initial }
        
        let values = base.map{$0.status.progress}
        let weights = base.map{$0.area.downloadSize}
        
        return weightedAverage(values: values, weights: weights) ?? 0.0
    }
    
    private func weightedAverage(values: [Double], weights: [Double]) -> Double? {
        guard values.count == weights.count else {
            print("The number of values and weights must be the same.")
            return nil
        }

        guard !weights.isEmpty else {
            print("Weights array must not be empty.")
            return nil
        }
        
        let weightedSum = zip(values, weights).map(*).reduce(0, +)
        
        let totalWeight = weights.reduce(0, +)
        
        guard totalWeight != 0 else {
            print("Total weight must not be zero.")
            return nil
        }
        
        return weightedSum / totalWeight
    }
}
