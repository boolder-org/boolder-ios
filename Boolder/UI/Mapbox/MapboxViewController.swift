//
//  MapboxViewController.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/10/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import UIKit
import MapboxMaps

class MapboxViewController: UIViewController {
    
    var mapView: MapView!
    var delegate: MapBoxViewDelegate!
    private var previouslyTappedProblemId: String = ""
    
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
        return StyleURI(rawValue: "mapbox://styles/nmondollot/cl95n147u003k15qry7pvfmq2/draft")!
    }()
    
    // Regions and style pack downloads
    private var downloads: [Cancelable] = []

    private let tokyoCoord = CLLocationCoordinate2D(latitude: 48.3777465, longitude: 2.5303744)
    private let tokyoZoom: CGFloat = 12
    private let tileRegionId = "trois-pignons-region"
    
    deinit {
        OfflineSwitch.shared.isMapboxStackConnected = true
        removeTileRegionAndStylePack()
    }
    
    func downloadTileRegions() {
        guard let tileStore = tileStore else {
            preconditionFailure()
        }

        precondition(downloads.isEmpty)

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
                }
            }
        }

        // - - - - - - - -

        // 2. Create an offline region with tiles for the outdoors style
        let outdoorsOptions = TilesetDescriptorOptions(styleURI: styleURI,
                                                       zoomRange: 0...16) // TODO: choose smaller range to limit download size

        let outdoorsDescriptor = offlineManager.createTilesetDescriptor(for: outdoorsOptions)

        let troisPignons = LineString(Ring(coordinates: [
            LocationCoordinate2D(latitude: 48.40140017969, longitude: 2.49835959435),
            LocationCoordinate2D(latitude: 48.37763243669, longitude: 2.50136366844),
            LocationCoordinate2D(latitude: 48.35710459296, longitude: 2.52943030357),
            LocationCoordinate2D(latitude: 48.35699052627, longitude: 2.54779807091),
            LocationCoordinate2D(latitude: 48.39228197451, longitude: 2.56659499168),
            LocationCoordinate2D(latitude: 48.40043144798, longitude: 2.55483618736),
            LocationCoordinate2D(latitude: 48.40533190133, longitude: 2.50539771080),
            LocationCoordinate2D(latitude: 48.40140017969, longitude: 2.49835959435),
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
                                                          loadOptions: tileRegionLoadOptions) { [weak self] (progress) in
            // These closures do not get called from the main thread. In this case
            // we're updating the UI, so it's important to dispatch to the main
            // queue.
            DispatchQueue.main.async {


                print("\(progress)")
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
                }
            }
        }

        // Wait for both downloads before moving to the next state
        dispatchGroup.notify(queue: .main) {
            self.downloads = []
            OfflineSwitch.shared.isMapboxStackConnected = false
            print("download finished")
            print("disable mapbox HTTP calls")
        }

        downloads = [stylePackDownload, tileRegionDownload]
    }
    
    private func cancelDownloads() {
        // Canceling will trigger `.canceled` errors that will then change state
        downloads.forEach { $0.cancel() }
    }
    
    // Remove downloaded region and style pack
    private func removeTileRegionAndStylePack() {
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
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
//        let myResourceOptions = ResourceOptions(accessToken: "pk.eyJ1Ijoibm1vbmRvbGxvdCIsImEiOiJjbDlyNHo2OGMwZjNyM3ZsNzk5d2M1NDVlIn0.HUjcpmT5EZyhuR_VjN6eog")
//
//        let cameraOptions = CameraOptions(
//            center: CLLocationCoordinate2D(latitude: 48.394842, longitude: 2.6318405),
//            zoom: 10
//        )
        
//        let myMapInitOptions = MapInitOptions(
//            resourceOptions: myResourceOptions,
//            cameraOptions: cameraOptions,
//            styleURI: styleURI
//        )
        
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Wait for the map to load its style before adding data.
        mapView.mapboxMap.onNext(event: .mapLoaded) { [self] _ in
            
            // Specify a unique string as the source ID (SOURCE_ID)
            let sourceIdentifier = "problems"
            var source = VectorSource()
            // In this case, the tileset is owned by the "mapbox" account
            // and "mapbox-terrain-v2" is the tileset ID
            source.url = "mapbox://nmondollot.4xsv235p"
            source.promoteId = .string("id")
            // Add the vector source to the style
            try! self.mapView.mapboxMap.style.addSource(source, id: sourceIdentifier)
            
            //            // Define bounding box
            //            let bounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: 48.2868427, longitude: 2.4806787),
            //                                          northeast: CLLocationCoordinate2D(latitude: 48.473906, longitude: 2.7698927))
            //
            //            // Center the camera on the bounds
            //            let cameraOptions = mapView.mapboxMap.camera(for: bounds, padding: .zero, bearing: 0, pitch: 0)
            //            mapView.mapboxMap.setCamera(to: cameraOptions)
            
            
            // Specify a unique string as the layer ID ("LAYER_ID")
            // and set the source to some source ID (SOURCE_ID).
            var problemsLayer = CircleLayer(id: "problems")
            problemsLayer.source = "problems"
            problemsLayer.sourceLayer = "problems-ayes3a"
            problemsLayer.minZoom = 15
            problemsLayer.filter = Expression(.match) {
                ["geometry-type"]
                ["Point"]
                true
                false
            }
            
            // Set some style properties
            problemsLayer.circleRadius = .expression(
                
                Exp(.interpolate) {
                    ["linear"]
                    ["zoom"]
                    15
                    2
                    18
                    4
                    22
                    16
                }
                
            )
            
            problemsLayer.circleColor = .expression(
                Exp(.match) {
                    Exp(.get) { "circuitColor" }
                    "yellow"
                    Circuit.CircuitColor.yellow.uicolor
                    "purple"
                    Circuit.CircuitColor.purple.uicolor
                    "orange"
                    Circuit.CircuitColor.orange.uicolor
                    "green"
                    Circuit.CircuitColor.green.uicolor
                    "blue"
                    Circuit.CircuitColor.blue.uicolor
                    "skyblue"
                    Circuit.CircuitColor.skyBlue.uicolor
                    "salmon"
                    Circuit.CircuitColor.salmon.uicolor
                    "red"
                    Circuit.CircuitColor.red.uicolor
                    "black"
                    Circuit.CircuitColor.black.uicolor
                    "white"
                    Circuit.CircuitColor.white.uicolor
                    Circuit.CircuitColor.offCircuit.uicolor
                }
            )
            
            problemsLayer.circleStrokeWidth = .expression(
                Exp(.switchCase) {
                    Exp(.boolean) {
                        Exp(.featureState) { "selected" }
                        false
                    }
                    2.0
                    0.0
                }
            )
            problemsLayer.circleStrokeColor = .constant(StyleColor(UIColor.white))
            
            let stopsB: [Double: Double] = [
                14.5: 0.0,
                15:   1.0,
            ]
            problemsLayer.circleOpacity = .expression(
                Exp(.interpolate) {
                    ["linear"]
                    ["zoom"]
                    stopsB
                }
            )
            
            // Add the circle layer to the map.
            try! self.mapView.mapboxMap.style.addLayer(problemsLayer)
            
            
            var problemsTextsLayer = SymbolLayer(id: "problems-texts")
            problemsTextsLayer.source = "problems"
            problemsTextsLayer.sourceLayer = "problems-ayes3a"
            problemsTextsLayer.minZoom = 19
            problemsTextsLayer.filter = Expression(.match) {
                ["geometry-type"]
                ["Point"]
                true
                false
            }
            
            problemsTextsLayer.textAllowOverlap = .constant(true)
            problemsTextsLayer.textField = .expression(
                Expression(.toString) {
                    ["get", "circuitNumber"]
                }
            )
            
            let stopsC: [Double: Double] = [
                19: 10,
                22: 20,
            ]
            problemsTextsLayer.textSize = .expression(
                Exp(.interpolate) {
                    ["linear"]
                    ["zoom"]
                    stopsC
                }
            )
            
            problemsTextsLayer.textColor = .expression(
                Expression(.switchCase) {
                    Expression(.match) {
                        ["get", "circuitColor"]
                        ["", "white"]
                        true
                        false
                    }
                    UIColor.black // use less dark
                    UIColor.white
                }
            )
            
            
            try! self.mapView.mapboxMap.style.addLayer(problemsTextsLayer)
            
//            applyFilter()
            
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.findFeatures))
            self.mapView.addGestureRecognizer(tapGesture)
        }
        
        self.view.addSubview(mapView)
        
        
        
        let tileStore = TileStore.default
        let accessToken = ResourceOptionsManager.default.resourceOptions.accessToken
        tileStore.setOptionForKey(TileStoreOptions.mapboxAccessToken, value: accessToken)
        self.tileStore = tileStore
        OfflineSwitch.shared.isMapboxStackConnected = true
    }
    
    func applyFilter() {
        do {
          
          try mapView.mapboxMap.style.updateLayer(withId: "problems", type: CircleLayer.self) { layer in
            // Update layer properties
              layer.filter = Expression(.match) {
                  Exp(.get) { "grade" }
                  ["1a","1a+","1b","1b+","1c","1c+","2a","2a+","2b","2b+","2c","2c+","3a","3a+","3b","3b+","3c","3c+",]
                  true
                  false
              }
          }
            
            try mapView.mapboxMap.style.updateLayer(withId: "problems-texts", type: SymbolLayer.self) { layer in
              // Update layer properties
                layer.filter = Expression(.match) {
                    Exp(.get) { "grade" }
                    ["1a","1a+","1b","1b+","1c","1c+","2a","2a+","2b","2b+","2c","2c+","3a","3a+","3b","3b+","3c","3c+",]
                    true
                    false
                }
            }
        } catch {
          print("Ran into an error updating the layer: \(error)")
        }
    }
    
    func removeFilter() {
        do {
        try mapView.mapboxMap.style.updateLayer(withId: "problems", type: CircleLayer.self) { layer in
          // Update layer properties
            layer.filter = Expression(.match) {
                Exp(.get) { "grade" }
                ["1a","1a+","1b","1b+","1c","1c+","2a","2a+","2b","2b+","2c","2c+","3a","3a+","3b","3b+","3c","3c+","4a","4a+","4b","4b+","4c","4c+","5a","5a+","5b","5b+","5c","5c+","6a","6a+","6b","6b+","6c","6c+","7a","7a+","7b","7b+","7c","7c+","8a","8a+","8b","8b+","8c","8c+","9a","9a+","9b","9b+","9c","9c+",]
                true
                false
            }
        }
          
          try mapView.mapboxMap.style.updateLayer(withId: "problems-texts", type: SymbolLayer.self) { layer in
            // Update layer properties
              layer.filter = Expression(.match) {
                  Exp(.get) { "grade" }
                  ["1a","1a+","1b","1b+","1c","1c+","2a","2a+","2b","2b+","2c","2c+","3a","3a+","3b","3b+","3c","3c+","4a","4a+","4b","4b+","4c","4c+","5a","5a+","5b","5b+","5c","5c+","6a","6a+","6b","6b+","6c","6c+","7a","7a+","7b","7b+","7c","7c+","8a","8a+","8b","8b+","8c","8c+","9a","9a+","9b","9b+","9c","9c+",]
                  true
                  false
              }
          }
      } catch {
        print("Ran into an error updating the layer: \(error)")
      }
    }
    
    
    @objc public func findFeatures(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: mapView)

        let zoomExpression = Expression(.lt) {
            Expression(.zoom)
            15
        }
        
        mapView.mapboxMap.queryRenderedFeatures(
            with: tapPoint,
            options: RenderedQueryOptions(layerIds: ["areas", "areas-hulls"], filter: zoomExpression)) { [weak self] result in
                
                guard let self = self else { return }
                
                switch result {
                case .success(let queriedfeatures):
                    
                    if let areaFeature = queriedfeatures.first?.feature
                    {
                        print(areaFeature.properties)
                    }
                case .failure(let error):
                    print("An error occurred: \(error.localizedDescription)")
                }
            }
        
        mapView.mapboxMap.queryRenderedFeatures(
            with: tapPoint,
            options: RenderedQueryOptions(layerIds: ["problems"], filter: nil)) { [weak self] result in
                
//                print("tap on problems layer")

            guard let self = self else { return }

            switch result {
            case .success(let queriedfeatures):

                // Extract the earthquake feature from the queried features
                if let problemFeature = queriedfeatures.first?.feature,
//                   case .number(let problemIdDouble) = problemFeature.identifier,
                   case .number(let id) = problemFeature.properties?["id"],
                   case .point(let point) = problemFeature.geometry
//                   case let .number(magnitude) = problemFeature.properties?["mag"]
                {
                    
//                    print(problemFeature.properties)
//
//                    print(id)
//                    print(point)
                    
//                    print(String(id))
                    
                    self.delegate?.selectProblem(id: Int(id)) // FIXME: make sure we cast to Int before running the rest of the code
                    
                    let problemFeatureId = String(Int(id))
                    
                    self.mapView.mapboxMap.setFeatureState(sourceId: "problems",
                                                           sourceLayerId: "problems-ayes3a",
                                                           featureId: problemFeatureId,
                                                           state: ["selected": true])
                    
                    

                    if self.previouslyTappedProblemId != ""
                        && problemFeatureId != self.previouslyTappedProblemId {
                        // Reset a previously tapped earthquake to be "unselected".
                        self.mapView.mapboxMap.setFeatureState(sourceId: "problems",
                                                               sourceLayerId: "problems-ayes3a",
                                                               featureId: self.previouslyTappedProblemId,
                                                               state: ["selected": false])
                    }
                    
                    self.previouslyTappedProblemId = problemFeatureId


//                    let earthquakeId = Int(earthquakeIdDouble).description
//
//                    // Set the description of the earthquake from the `properties` object
//                    self.setDescription(magnitude: magnitude, timeStamp: timestamp, location: place)
//
//                    // Set the earthquake to be "selected"
//                    self.setSelectedState(earthquakeId: earthquakeId)
//
//                    // Reset a previously tapped earthquake to be "unselected".
//                    self.resetPreviouslySelectedStateIfNeeded(currentTappedEarthquakeId: earthquakeId)
//
//                    // Store the currently tapped earthquake so it can be reset when another earthquake is tapped.
//                    self.previouslyTappedEarthquakeId = earthquakeId
//
//                    // Center the selected earthquake on the screen
//                    self.mapView.camera.fly(to: CameraOptions(center: point.coordinates, zoom: 10))
                }
            case .failure(let error):
                print("An error occurred: \(error.localizedDescription)")
            }
        }
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


protocol MapBoxViewDelegate {

    // Define expected delegate functions
    func selectProblem(id: Int)
}
