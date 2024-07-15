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
class AreaNewDownloader: Identifiable, ObservableObject {
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
        
    }
    
    func getTopoList() async throws {
        let url = URL(string: "https://www.boolder.com/api/v1/areas/\(areaId)/topos.json")!
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let topoArray = try? JSONDecoder().decode([TopoJson].self, from: data) {
                
                for topo in topoArray {
                    print("Topo ID: \(topo.topoID), URL: \(topo.url)")
                }
                
                let a = topoArray.map{TopoData(id: $0.topoID, url: URL(string: $0.url)!)}
                
                let downloader = Downloader(maxRetries: 3)
                Task {
                    await downloader.downloadFiles(a)
                }
            }
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
