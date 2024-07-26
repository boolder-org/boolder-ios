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
    
    @Published var queueRunning = false
    
    var cancellables = [AnyCancellable]()
    
    init(cluster: Cluster, mainArea: Area) {
        self.cluster = cluster
        
        areas = cluster.areasSortedByDistance(mainArea).map { area in
            DownloadCenter.shared.areaDownloader(id: area.id)
        }
        
        print(areas.first!.area)
        
        // hack to make sure we publish changes when any of the AreaDownloader publishes a change
        // inspired by https://stackoverflow.com/a/57302695
        self.areas.forEach { area in
            let c = area.objectWillChange
                .throttle(for: .milliseconds(500), scheduler: RunLoop.main, latest: true)
                .sink(receiveValue: { self.objectWillChange.send() })
            self.cancellables.append(c)
        }
    }
    
    func start() {
        // TODO: use same sort logic as the UI
        areas.filter{ $0.status == .initial }.forEach{ $0.queue() }

        startQueueIfNeeded()
    }
    
    func addAreaToQueue(_ area: AreaDownloader) {
        area.queue()
        startQueueIfNeeded()
    }
    
    private func startQueueIfNeeded() {
        if !queueRunning {
            startQueue()
        }
    }
    
    private func startQueue() {
        queueRunning = true
        
        if let area = (areas.first { $0.status == .queued }) {
            area.start(onSuccess: { [self] in
                self.startQueue()
                
                }, onFailure: { [self] in
                   stopDownloads()
                })
        }
        else {
            queueRunning = false
//            print("queue done")
        }
    }
    
    func stopDownloads() {
        areas.filter{ $0.status.downloadingOrQueued }.forEach{ $0.cancel() }
        
        queueRunning = false
        
//        currentDownloader = nil
        
//        currentDownloader?.cancel()
//        downloadQueue = []
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
