//
//  AreaDownloader.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 15/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import Foundation
import Combine

// we use separate objects to avoid redrawing the entire swiftui views everytime
// it probably won't be necessary anymore with iOS 17's @Observable
class AreaDownloader: Identifiable, ObservableObject {
    let areaId: Int
    @Published var status: DownloadStatus
    var cancellable: Cancellable?
    
    var task: Task<(), any Error>?
    
    init(areaId: Int) {
        self.areaId = areaId
        self.status = .initial
    }
    
    // TODO: rename to loadStatus()
    func updateStatus() {
        if alreadyDownloaded {
            DispatchQueue.main.async{
                self.status = .downloaded
            }
        }
    }
    
    func start() {
        if alreadyDownloaded {
            DispatchQueue.main.async{
                self.status = .downloaded
            }
        }
        else {
            DispatchQueue.main.async{
                // TODO: show some progress before we get the topos list?
                self.status = .downloading(progress: 0.0)
            }
            
            self.task = Task {
                let topos = area.topos
                print("\(topos.count) topos to download")
                
                let downloader = Downloader()
                
                self.cancellable = downloader.$progress.receive(on: DispatchQueue.main)
                    .sink() { progress in
                        self.status = .downloading(progress: progress)
                    }
                
                await downloader.downloadFiles(topos: topos, onSuccess: { [self] in
                    DispatchQueue.main.async{
                        self.status = .downloaded
                        self.createSuccessfulDownloadFile()
                    }
                    
                }, onFailure: { [self] in
                    DispatchQueue.main.async{
                        print("Error downloading")
                        self.status = .initial
                    }
                })
                
            }
        }
    }
    
    func cancel() {
        // TODO: what if download is already finished?
        
        self.task?.cancel()
        
        cancellable = nil
        
        // TODO: should we delete folder?
//        deleteFolder()
        
        status = .initial
    }
    
    func remove() {
        cancellable = nil
        
        deleteFolder()
        status = .initial
    }
    
    private var successfulDownloadFile: URL {
        Downloader.onDiskFolder(areaId: areaId).appendingPathComponent("downloaded")
    }

    private func createSuccessfulDownloadFile() {
        if !FileManager.default.createFile(atPath: successfulDownloadFile.path, contents: nil, attributes: nil) {
            print("Failed to create downloaded file for area \(areaId)")
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
        case downloading(progress: Double)
        case downloaded
        
        var label: String {
            switch self {
            case .downloaded:
                "downloaded"
            case .initial:
                "-"
            case .downloading(progress: let progress):
                "\(Int(progress*100))%"
            }
        }
    }
}
