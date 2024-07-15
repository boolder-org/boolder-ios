//
//  AreaNewDownloader.swift
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
    
    init(areaId: Int, status: DownloadStatus) {
        self.areaId = areaId
        self.status = status
    }
    
    var id: Int {
        areaId
    }
    
    var area: Area {
        Area.load(id: areaId)!
    }
    
    func requestAndStartDownload() {
        DownloadSettings.shared.addArea(areaId: areaId)
        start()
    }
    
    func remove() {
//        odrManager.stop()
        status = .initial
        
        DownloadSettings.shared.removeArea(areaId: areaId)
    }
    
    func cancel() {
        // TODO: what if download is already finished?
//        odrManager.cancel()
        status = .initial
        
        DownloadSettings.shared.removeArea(areaId: areaId)
    }
    
    func start() {
        if alreadyDownloaded {
            DispatchQueue.main.async{
                self.status = .downloaded
            }
        }
        else {
            DispatchQueue.main.async{
                self.status = .downloading(progress: 0.0)
            }
            
            Task {
                let downloader = try await Downloader(maxRetries: 3, topos: getTopoList())
                
                self.cancellable = downloader.$progress.receive(on: DispatchQueue.main)
                    .sink() { progress in
                        self.status = .downloading(progress: progress)
                    }
                
                await downloader.downloadFiles(onSuccess: { [self] in
                    DispatchQueue.main.async{
                        self.status = .downloaded
                        self.createDownloadedFile()
                    }
                    
                }, onFailure: { error in
                    DispatchQueue.main.async{
                        print("Error downloading")
                        self.status = .initial
                    }
                })
            }
        }
    }
    
    private func getTopoList() async throws -> [TopoData] {
        let url = URL(string: "https://www.boolder.com/api/v1/areas/\(areaId)/topos.json")!
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let topoArray = try? JSONDecoder().decode([TopoJson].self, from: data) {
                
                for topo in topoArray {
                    print("Topo ID: \(topo.topoID), URL: \(topo.url)")
                }
                
                return topoArray.map{TopoData(id: $0.topoID, url: URL(string: $0.url)!, areaId: areaId)}
            }
        }
        
        return []
    }

    private func createDownloadedFile() {
        print("DOWNLOADED")
        
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
        case requested
        case downloading(progress: Double)
        case downloaded
        case failed
        
        var label: String {
            switch self {
            case .downloaded:
                "downloaded"
            case .initial:
                "-"
            case .downloading(progress: let progress):
                "\(Int(progress*100))%"
            case .failed:
                "failed"
            case .requested:
                "requested"
            }
        }
    }
}
