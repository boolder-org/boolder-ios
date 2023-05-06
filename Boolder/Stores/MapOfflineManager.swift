//
//  MapOfflineManager.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 06/05/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import Foundation
import MapboxMaps
import CoreLocation

class MapOfflineManager : ObservableObject {
    static let shared = MapOfflineManager()
    
    enum Status : String {
        case initial
        case downloading
        case error
        case finished
    }
    
    @Published var status: Status = .initial
    @Published var progress = 0.0
    
    private var tileStore: TileStore?

    // Default MapInitOptions. If you use a custom path for a TileStore, you would
    // need to create a custom MapInitOptions to reference that TileStore.
    private lazy var mapInitOptions: MapInitOptions = {
        MapInitOptions(cameraOptions: CameraOptions(center: tokyoCoord, zoom: tokyoZoom),
                       styleURI: styleURI)
    }()
    
    private lazy var offlineManager: OfflineManager = {
        return OfflineManager(resourceOptions: mapInitOptions.resourceOptions)
    }()
    
    private lazy var styleURI: StyleURI = {
        return StyleURI(rawValue: "mapbox://styles/nmondollot/cl95n147u003k15qry7pvfmq2")!
    }()
    
    // Regions and style pack downloads
    private var downloads: [Cancelable] = []
    
    private let tokyoCoord = CLLocationCoordinate2D(latitude: 48.3777465, longitude: 2.5303744)
    private let tokyoZoom: CGFloat = 12
    private let tileRegionId = "trois-pignons-region"
    
    init() {
        let tileStore = TileStore.default
        let accessToken = ResourceOptionsManager.default.resourceOptions.accessToken
        tileStore.setOptionForKey(TileStoreOptions.mapboxAccessToken, value: accessToken)
        self.tileStore = tileStore
        OfflineSwitch.shared.isMapboxStackConnected = true
    }
    
    deinit {
        OfflineSwitch.shared.isMapboxStackConnected = true
        removeTileRegionAndStylePack()
    }
    
    func downloadTileRegions() {
        guard let tileStore = tileStore else {
            preconditionFailure()
        }
        
        precondition(downloads.isEmpty)
        
        self.status = .downloading
        
        let dispatchGroup = DispatchGroup()
        var downloadError = false
        
        // - - - - - - - -
        // 1. Create style package with loadStylePack() call.
        let stylePackLoadOptions = StylePackLoadOptions(glyphsRasterizationMode: .ideographsRasterizedLocally,
                                                        metadata: ["tag": "my-outdoors-style-pack"])!
        
        dispatchGroup.enter()
        let stylePackDownload = offlineManager.loadStylePack(for: styleURI, loadOptions: stylePackLoadOptions) { [weak self] progress in
            // These closures do not get called from the main thread. In this case
            // we're updating the UI, so it's important to dispatch to the main
            // queue.
            DispatchQueue.main.async {
                print(Float(progress.completedResourceCount) / Float(progress.requiredResourceCount))
            }
            
        } completion: { [weak self] result in
            DispatchQueue.main.async {
                defer {
                    dispatchGroup.leave()
                }
                
                switch result {
                case let .success(stylePack):
                    print("StylePack = \(stylePack)")
                    
                case let .failure(error):
                    print("stylePack download Error = \(error)")
                    downloadError = true
                    self?.status = .error
                }
            }
        }
        
        // - - - - - - - -
        // 2. Create an offline region with tiles for the outdoors style
        let outdoorsOptions = TilesetDescriptorOptions(styleURI: styleURI,
                                                       zoomRange: 0...16) // TODO: choose smaller range to limit download size
        let outdoorsDescriptor = offlineManager.createTilesetDescriptor(for: outdoorsOptions)
        
        let troisPignons = LineString(Ring(coordinates: [
            LocationCoordinate2D(latitude: 48.47701838737, longitude: 2.63465847015),
            LocationCoordinate2D(latitude: 48.44150103985, longitude: 2.58521999359),
            LocationCoordinate2D(latitude: 48.37882980986, longitude: 2.47775997162),
            LocationCoordinate2D(latitude: 48.31448308901, longitude: 2.52788509369),
            LocationCoordinate2D(latitude: 48.25439856060, longitude: 2.63706172943),
            LocationCoordinate2D(latitude: 48.25188397947, longitude: 2.70229305267),
            LocationCoordinate2D(latitude: 48.27473926015, longitude: 2.68993343353),
            LocationCoordinate2D(latitude: 48.31539637649, longitude: 2.61680568695),
            LocationCoordinate2D(latitude: 48.36788291368, longitude: 2.55466426849),
            LocationCoordinate2D(latitude: 48.43990673015, longitude: 2.66864742279),
            LocationCoordinate2D(latitude: 48.47110055512, longitude: 2.68890346527),
            LocationCoordinate2D(latitude: 48.47701838737, longitude: 2.63465847015),
        ]))
        
        // Load the tile region
        let tileRegionLoadOptions = TileRegionLoadOptions(
            geometry: .lineString(troisPignons),
            descriptors: [outdoorsDescriptor],
            metadata: ["tag": "my-outdoors-tile-region"],
            acceptExpired: true)!
        
        // Use the the default TileStore to load this region. You can create
        // custom TileStores are are unique for a particular file path, i.e.
        // there is only ever one TileStore per unique path.
        dispatchGroup.enter()
        let tileRegionDownload = tileStore.loadTileRegion(forId: tileRegionId,
                                                          loadOptions: tileRegionLoadOptions) { [weak self] (tileProgress) in
            // These closures do not get called from the main thread. In this case
            // we're updating the UI, so it's important to dispatch to the main
            // queue.
            DispatchQueue.main.async {
                self?.progress = Double(tileProgress.completedResourceCount / tileProgress.requiredResourceCount)
                
                print("\(tileProgress)")
            }
        } completion: { [weak self] result in
            DispatchQueue.main.async {
                defer {
                    dispatchGroup.leave()
                }
                
                switch result {
                case let .success(tileRegion):
                    print("tileRegion = \(tileRegion)")
                    
                case let .failure(error):
                    print("tileRegion download Error = \(error)")
                    downloadError = true
                    self?.status = .error
                }
            }
        }
        
        // Wait for both downloads before moving to the next state
        dispatchGroup.notify(queue: .main) {
            self.downloads = []
//            OfflineSwitch.shared.isMapboxStackConnected = false
            print("download finished")
//            print("disable mapbox HTTP calls")
            
            self.status = .finished
        }
        
        downloads = [stylePackDownload, tileRegionDownload]
    }
    
    private func cancelDownloads() {
        // Canceling will trigger `.canceled` errors that will then change state
        downloads.forEach { $0.cancel() }
        status = .error
    }
    
    // Remove downloaded region and style pack
    func removeTileRegionAndStylePack() {
        // Clean up after the example. Typically, you'll have custom business
        // logic to decide when to evict tile regions and style packs
        // Remove the tile region with the tile region ID.
        // Note this will not remove the downloaded tile packs, instead, it will
        // just mark the tileset as not a part of a tile region. The tiles still
        // exists in a predictive cache in the TileStore.
        tileStore?.removeTileRegion(forId: tileRegionId)
        
        // Set the disk quota to zero, so that tile regions are fully evicted
        // when removed. The TileStore is also used when `ResourceOptions.isLoadTilePacksFromNetwork`
        // is `true`, and also by the Navigation SDK.
        // This removes the tiles from the predictive cache.
        tileStore?.setOptionForKey(TileStoreOptions.diskQuota, value: 0)
        
        // Remove the style pack with the style uri.
        // Note this will not remove the downloaded style pack, instead, it will
        // just mark the resources as not a part of the existing style pack. The
        // resources still exists in the disk cache.
        offlineManager.removeStylePack(for: styleURI)
        
        status = .initial
    }
}


// MARK: - Convenience classes for tile and style classes
 extension TileRegionLoadProgress {
     public override var description: String {
         "TileRegionLoadProgress: \(completedResourceCount) / \(requiredResourceCount)"
     }
 }

 extension StylePackLoadProgress {
     public override var description: String {
         "StylePackLoadProgress: \(completedResourceCount) / \(requiredResourceCount)"
     }
 }

 extension TileRegion {
     public override var description: String {
         let fileSizeWithUnit = ByteCountFormatter.string(fromByteCount: Int64(completedResourceSize), countStyle: .file)
         return "TileRegion \(id): \(completedResourceCount) / \(requiredResourceCount) — size: \(fileSizeWithUnit)"
     }
 }

 extension StylePack {
     public override var description: String {
         "StylePack \(styleURI): \(completedResourceCount) / \(requiredResourceCount)"
     }
 }
