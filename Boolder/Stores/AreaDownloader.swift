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
    
    var id: Int {
        areaId
    }
    
    var area: Area {
        Area.load(id: areaId)!
    }
    
    func requestAndStartDownload() {
//        DownloadSettings.shared.addArea(areaId: areaId)
        start()
    }
    
    func remove() {
        cancellable = nil
        
        deleteFolder()
        status = .initial
        
//        DownloadSettings.shared.removeArea(areaId: areaId)
    }
    
    func cancel() {
        // TODO: what if download is already finished?
        
        self.task?.cancel()
        
        cancellable = nil
        
        // TODO: should we delete folder?
//        deleteFolder()
        
        status = .initial
        
//        DownloadSettings.shared.removeArea(areaId: areaId)
    }
    
    // TODO: rename
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
                        self.createDownloadedFile()
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

    private func createDownloadedFile() {
//        print("DOWNLOADED")
        
        // Step 1: Get the path to the caches directory
        let fileManager = FileManager.default
        guard let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            print("Could not find caches directory")
            return
        }
        
        // Step 2: Construct the file path for ".downloaded"
        let downloadedFilePath = cachesDirectory.appendingPathComponent("area-\(areaId)").appendingPathComponent("downloaded")
        
        // Step 3: Create an empty file at that path
        let success = fileManager.createFile(atPath: downloadedFilePath.path, contents: nil, attributes: nil)
        
        if success {
            print("Successfully created .downloaded file in caches directory")
        } else {
            print("Failed to create .downloaded file in caches directory")
        }
    }
    
    var alreadyDownloaded : Bool {
        // Get the path to the caches directory
        let fileManager = FileManager.default
        guard let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            print("Could not find caches directory")
            return false
        }
        
        let downloadedFilePath = cachesDirectory.appendingPathComponent("area-\(areaId)").appendingPathComponent("downloaded")
        
        return fileManager.fileExists(atPath: downloadedFilePath.path)
    }
    
    func deleteFolder() {
        
        let fileManager = FileManager.default
        
        guard let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            print("Could not find caches directory")
            return
        }
        
        let folder = cachesDirectory.appendingPathComponent("area-\(areaId)")

        do {
            // Check if the folder exists
            if fileManager.fileExists(atPath: folder.path) {
                // Attempt to remove the folder and its contents
                try fileManager.removeItem(at: folder)
                print("Folder deleted successfully.")
            } else {
                print("Folder does not exist at path: \(folder)")
            }
        } catch {
            // Handle the error
            print("Error while deleting folder: \(error)")
        }
    }
    
    enum DownloadStatus: Equatable {
        case initial
//        case requested
        case downloading(progress: Double)
        case downloaded
//        case failed
        
        var label: String {
            switch self {
            case .downloaded:
                "downloaded"
            case .initial:
                "-"
            case .downloading(progress: let progress):
                "\(Int(progress*100))%"
//            case .failed:
//                "failed"
//            case .requested:
//                "requested"
            }
        }
    }
}
