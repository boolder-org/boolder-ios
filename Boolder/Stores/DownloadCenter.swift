//
//  OfflineManager.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/11/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import Foundation
import Combine

class DownloadCenter: ObservableObject {
    static let shared = DownloadCenter()
    
    private var allAreas = [AreaDownloader]()
    @Published var requestedAreas = [AreaDownloader]()
    
    let settings = DownloadSettings.shared
    var cancellable: Cancellable?
    
    private init() {
        allAreas = Area.all.sorted{
            $0.name.folding(options: .diacriticInsensitive, locale: .current) < $1.name.folding(options: .diacriticInsensitive, locale: .current)
        }.map { area in
            AreaDownloader(areaId: area.id, status: settings.areaIds.contains(area.id) ? .requested : .initial)
        }
        
        cancellable = settings.$areaIds
            .map { $0.map{self.areaDownloader(id: $0)} }
            .assign(to: \.requestedAreas, on: self)
    }
    
    func start() {
        requestedAreas.forEach { areaDownloader in
            areaDownloader.start()
        }
    }
    
    func areaDownloader(id: Int) -> AreaDownloader {
        allAreas.first { areaDownloader in
            areaDownloader.id == id
        }! // FIXME: use a dedicated error
    }
}

// we use separate objects to avoid redrawing the entire swiftui views everytime
// it probably won't be necessary anymore with iOS 17's @Observable
class AreaDownloader: Identifiable, ObservableObject {
    let areaId: Int
    @Published var status: DownloadStatus
    let odrManager = ODRManager()
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
        odrManager.stop()
        status = .initial
        
        DownloadSettings.shared.removeArea(areaId: areaId)
    }
    
    func cancel() {
        // TODO: what if download is already finished?
        odrManager.cancel()
        status = .initial
        
        DownloadSettings.shared.removeArea(areaId: areaId)
    }
    
    func start() {
        let tags = Set(["area-\(areaId)"])
        
        odrManager.checkResources(tags: tags) { available in
            if available {
                DispatchQueue.main.async{
                    self.status = .downloaded
                }
            }
            else {
                DispatchQueue.main.async{
                    self.status = .downloading(progress: 0.0)
                }
                self.cancellable = self.odrManager.$downloadProgress.receive(on: DispatchQueue.main)
                    .sink() { progress in
                        self.status = .downloading(progress: progress)
                    }
                
                self.odrManager.requestResources(tags: tags, onSuccess: { [self] in
                    DispatchQueue.main.async{
                        self.status = .downloaded
                    }
                    
                }, onFailure: { error in
                    DispatchQueue.main.async{
                        print("On-demand resource error")
                        self.status = .initial
                    }
                    
                    // TODO: implement UI, log errors
                    switch error.code {
                    case NSBundleOnDemandResourceOutOfSpaceError:
                        print("You don't have enough space available to download this resource.")
                    case NSBundleOnDemandResourceExceededMaximumSizeError:
                        print("The bundle resource was too big.")
                    case NSBundleOnDemandResourceInvalidTagError:
                        print("The requested tag does not exist.")
                    default:
                        print(error.description)
                    }
                })
            }
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
