//
//  OfflineManager.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/11/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import Foundation
import Combine

class OfflineManager: ObservableObject {
    static let shared = OfflineManager()
    
    private var requestedAreas: Set<Int> = Set([1,4,5,6,7])
    
    @Published var offlineAreas = [OfflineArea]()
    
    private init() {
        offlineAreas = Area.all.sorted{
            $0.name.folding(options: .diacriticInsensitive, locale: .current) < $1.name.folding(options: .diacriticInsensitive, locale: .current)
        }.map { area in
            OfflineArea(areaId: area.id, status: requestedAreas.contains(area.id) ? .requested : .initial)
        }
    }
    
    func start() {
        offlineAreas.forEach { offlineArea in
            if requestedAreas.contains(offlineArea.areaId) {
                
                offlineArea.download()
                
            }
        }
    }
}

class OfflineArea: Identifiable, ObservableObject {
    let areaId: Int
    @Published var status: DownloadStatus
    let odrManager = ODRManager()
    var cancellable: Cancellable?
    
    init(areaId: Int, status: DownloadStatus) {
        self.areaId = areaId
        self.status = status
        
//        odrManager.downloadProgress
    }
    
    var id: Int {
        areaId
    }
    
    var area: Area {
        Area.load(id: areaId)!
    }
    
    func download() {
        print("downloading area \(areaId)")
        
        status = .downloading(progress: 0.0)
        self.cancellable = odrManager.$downloadProgress.receive(on: DispatchQueue.main)
            .sink() { progress in
                self.status = .downloading(progress: progress)
            }
        
        // FIXME: Make tag name DRY
        odrManager.requestResources(tags: Set(["area-\(areaId)"]), onSuccess: { [self] in
            print("downloaded area \(areaId)")
            DispatchQueue.main.async{
                self.status = .downloaded
            }
            
        }, onFailure: { error in
            print("On-demand resource error")
            self.status = .failed
            
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
    
    enum DownloadStatus {
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
                "error"
            case .requested:
                "waiting"
            }
            
        }
    }
    
    
}
