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

// ======================================================================================================================================================
//
// **Notes for future reference**
//
// This proof-of-concept works but has several drawbacks:
// - weird bugs like poi_routes not showing up at some zoom levels (because of "source compositing")
// - takes a lot of MBs on disk (way more than mapbox's default caching strategy)
// - needs a UI to manually delete downloaded regions
//
// Whereas the normal experience (without any offline shenanigans) is actually quite good:
// - the map loads in a few seconds even in 3G/Edge
// - the user just needs to open the map once and the SDK will automatically cache the data inside the current viewport + everything few kms around
//   which means that if a user opens Cuvier just once, the map data for Cuvier Ouest, Est, Rempart, Merveille, etc, will be available offline
//
// Conclusion: we prefer to avoid using the offline SDK for now. Too much added complexity for too few benefits.
//
// Must-read:
// https://docs.mapbox.com/ios/maps/guides/offline/
// https://docs.mapbox.com/ios/maps/guides/cache-management/
//
// ======================================================================================================================================================

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
        MapInitOptions(cameraOptions: CameraOptions(center: centerCoord, zoom: centerZoom),
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
    
    private let centerCoord = CLLocationCoordinate2D(latitude: 48.3777465, longitude: 2.5303744)
    private let centerZoom: CGFloat = 12
    private let tileRegionId = "test-region"
    
    init() {
        let tileStore = TileStore.default
        let accessToken = ResourceOptionsManager.default.resourceOptions.accessToken
        tileStore.setOptionForKey(TileStoreOptions.mapboxAccessToken, value: accessToken)
        self.tileStore = tileStore
        OfflineSwitch.shared.isMapboxStackConnected = true
    }
    
//    deinit {
//        OfflineSwitch.shared.isMapboxStackConnected = true
//        removeTileRegionAndStylePack()
//    }
    
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
                                                       zoomRange: 12...22) // TODO: choose smaller range to limit download size
        let outdoorsDescriptor = offlineManager.createTilesetDescriptor(for: outdoorsOptions)
        
        let buthiers = LineString(Ring(coordinates: [
            LocationCoordinate2D(latitude: 48.2943032, longitude: 2.4282637),
            LocationCoordinate2D(latitude: 48.2953098, longitude: 2.4326195),
        ]))
        
        let isatis = LineString(Ring(coordinates: [
            LocationCoordinate2D(latitude: 48.410886, longitude: 2.598622),
            LocationCoordinate2D(latitude: 48.4077856, longitude: 2.6074266),
        ]))
        
        let cuisiniere = LineString(Ring(coordinates: [
            LocationCoordinate2D(latitude: 48.4108184, longitude: 2.6101277),
            LocationCoordinate2D(latitude: 48.409517, longitude: 2.6145689),
        ]))
        
        var dls = [Cancelable]()
        
        
        
        Area.all.prefix(3).forEach { area in
            let zone = LineString(Ring(coordinates: [
                LocationCoordinate2D(latitude: area.northEastLat, longitude: area.northEastLon),
                LocationCoordinate2D(latitude: area.southWestLat, longitude: area.southWestLon),
            ]))
            
            
            // Load the tile region
            let tileRegionLoadOptions = TileRegionLoadOptions(
                geometry: .lineString(zone),
                descriptors: [outdoorsDescriptor],
                metadata: ["tag": "tag-area-\(area.id)"])!
            
            // Use the the default TileStore to load this region. You can create
            // custom TileStores are are unique for a particular file path, i.e.
            // there is only ever one TileStore per unique path.
            dispatchGroup.enter()
            let tileRegionDownload = tileStore.loadTileRegion(forId: "tile-area-\(area.id)",
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
            
            dls.append(tileRegionDownload)
            
        }
        
        
        
        
        // Wait for both downloads before moving to the next state
        dispatchGroup.notify(queue: .main) {
            self.downloads = []
//            OfflineSwitch.shared.isMapboxStackConnected = false
            print("download finished")
//            print("disable mapbox HTTP calls")
            
            self.status = .finished
        }
        
        downloads = [stylePackDownload] + dls
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
        tileStore?.removeTileRegion(forId: tileRegionId) // TODO: do the same for all regions
        
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
