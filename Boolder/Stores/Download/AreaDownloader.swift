//
//  AreaDownloader.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 15/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import Foundation
import Combine

@Observable
class AreaDownloader: Identifiable {
    let areaId: Int
    var status: DownloadStatus
    
    @ObservationIgnored var cancellable: Cancellable?
    @ObservationIgnored var task: Task<(), any Error>?
    
    init(areaId: Int) {
        self.areaId = areaId
        self.status = .initial
    }
    
    func loadStatus() {
        if alreadyDownloaded {
            DispatchQueue.main.async { self.status = .downloaded }
        }
    }
    
    func start(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        guard downloadingOrQueued else { return }
        
        DispatchQueue.main.async {
            self.status = .downloading(progress: 0.0)
        }
        
        self.task = Task {
            let topos = area.topos
            let downloader = Downloader()
            
            self.cancellable = downloader.progressPublisher
                .receive(on: DispatchQueue.main)
                .sink() { progress in
                    self.status = .downloading(progress: progress)
                }
            
            await downloader.downloadFiles(topos: topos, onSuccess: { [self] in
                DispatchQueue.main.async {
                    self.status = .downloaded
                    self.createSuccessfulDownloadFile()
                    onSuccess()
                }
                
            }, onFailure: { [self] in
                DispatchQueue.main.async {
                    self.status = .initial
                    onFailure()
                }
            })
        }
        
    }
    
    func queue() {
        self.status = .queued
    }
    
    func cancel() {
        self.task?.cancel()
        cancellable = nil
        
        status = .initial
    }
    
    func remove() {
        deleteFolder()
        cancellable = nil
        
        status = .initial
    }
    
    var downloadingOrQueued: Bool {
        status.downloadingOrQueued
    }
    
    private var successfulDownloadFile: URL {
        Downloader.onDiskFolder(areaId: areaId).appendingPathComponent("downloaded")
    }

    private func createSuccessfulDownloadFile() {
        if !FileManager.default.createFile(atPath: successfulDownloadFile.path, contents: nil, attributes: nil) {
            print("Failed to create succesful download file for area \(areaId)")
        }
    }
    
    var alreadyDownloaded: Bool {
        FileManager.default.fileExists(atPath: successfulDownloadFile.path)
    }
    
    private func deleteFolder() {
        let folder = Downloader.onDiskFolder(areaId: areaId)
        try? FileManager.default.removeItem(at: folder)
    }
    
    var id: Int {
        areaId
    }
    
    var area: Area {
        Area.load(id: areaId)!
    }
    
    enum DownloadStatus: Equatable {
        case initial
        case queued
        case downloading(progress: Double)
        case downloaded
        
        var downloadingOrQueued: Bool {
            if case .downloading(_) = self {
                return true
            }
            else if case .queued = self {
                return true
            }
            
            return false
        }
        
        var progress: Double {
            if case .downloading(let p) = self {
                return p
            }
            else if case .downloaded = self {
                return 1.0
            }
            
            return 0.0
        }
        
        var label: String {
            switch self {
            case .downloaded:
                "downloaded"
            case .initial:
                "-"
            case .downloading(progress: let progress):
                "\(Int(progress*100))%"
            case .queued:
                "queued"
            }
        }
    }
}
