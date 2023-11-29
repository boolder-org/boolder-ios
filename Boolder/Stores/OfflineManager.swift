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
    
    private var requestedAreas: Set<Int>  // = Set([1,4,5,6,7])
    {
        get {
            guard let data = UserDefaults.standard.data(forKey: "mySet"),
                  let decodedSet = try? JSONDecoder().decode(Set<Int>.self, from: data) else {
                return []
            }
            return decodedSet
        }
        set {
            if let encodedData = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encodedData, forKey: "mySet")
            }
        }
    }
    
    @Published var offlineAreas = [OfflineArea]()
    
    private init() {
        offlineAreas = Area.all.sorted{
            $0.name.folding(options: .diacriticInsensitive, locale: .current) < $1.name.folding(options: .diacriticInsensitive, locale: .current)
        }.map { area in
            OfflineArea(areaId: area.id, status: requestedAreas.contains(area.id) ? .requested : .initial)
        }
    }
    
    func requestArea(areaId: Int) {
        requestedAreas.insert(areaId)
    }
    
    func start() {
        offlineAreas.forEach { offlineArea in
            if requestedAreas.contains(offlineArea.areaId) {
                // TODO: handle case when area is already available
                offlineArea.download()
                
            }
        }
    }
    
    func offlineArea(withId id: Int) -> OfflineArea {
        offlineAreas.first { offlineArea in
            offlineArea.id == id
        }! // FIXME
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
        let tags = Set(["area-\(areaId)"])
        
        odrManager.checkResources(tags: tags) { available in
            if available {
                print("available area \(self.areaId)")
                self.status = .downloaded
            }
            else {
                print("downloading area \(self.areaId)")
                
                DispatchQueue.main.async{
                    self.status = .downloading(progress: 0.0)
                }
                self.cancellable = self.odrManager.$downloadProgress.receive(on: DispatchQueue.main)
                    .sink() { progress in
                        self.status = .downloading(progress: progress)
                        print("progress = \(progress)")
                    }
                
                // FIXME: Make tag name DRY
                self.odrManager.requestResources(tags: tags, onSuccess: { [self] in
                    print("downloaded area \(areaId)")
                    DispatchQueue.main.async{
                        self.status = .downloaded
                        print("status = downloaded")
                    }
                    
                }, onFailure: { error in
                    DispatchQueue.main.async{
                        print("On-demand resource error")
                        self.status = .failed
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
