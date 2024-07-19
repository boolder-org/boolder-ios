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
//    let odrManager = ODRManager()
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
                let topos = try await getTopoList()
                
                print("\(topos.count) topos to download")
                
                // TODO: use an exception instead of an empty list?
                if(topos.isEmpty) {
                    DispatchQueue.main.async{
                        print("No topos")
                        self.status = .initial
                    }
                }
                else {
                    
                    let downloader = Downloader(maxRetries: 3, topos: topos)
                    
                    self.cancellable = downloader.$progress.receive(on: DispatchQueue.main)
                        .sink() { progress in
                            self.status = .downloading(progress: progress)
                        }
                    
                    await downloader.downloadFiles(onSuccess: { [self] in
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
    }
    
    private func getTopoList() async -> [TopoData] {
        let url = URL(string: "https://www.boolder.com/api/v1/areas/\(areaId)/topos.json")!
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let topoArray = try? JSONDecoder().decode([TopoJson].self, from: data) {
                
//                for topo in topoArray {
//                    print("Topo ID: \(topo.topoID), URL: \(topo.url)")
//                }
                
                return topoArray.map{TopoData(id: $0.topoID, url: URL(string: $0.url)!, areaId: areaId)}
            }
        }
        catch {
            return [] // FIXME: don't return empty array
        }
        
        return [] // FIXME: don't return empty array
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
    
    
    
    struct TopoJson: Codable {
        let topoID: Int
        let url: String
        
        // Define the coding keys to match the JSON keys
        enum CodingKeys: String, CodingKey {
            case topoID = "topo_id"
            case url
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
