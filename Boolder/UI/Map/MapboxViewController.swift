//
//  MapboxViewController.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/10/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import UIKit
import MapboxMaps
import CoreLocation

class MapboxViewController: UIViewController {
    var mapView: MapView!
    var delegate: MapBoxViewDelegate?
    var cancelables = Set<AnyCancelable>()
    
    // Map styles for light and dark mode
    private let lightStyleURI = StyleURI(rawValue: "mapbox://styles/nmondollot/cl95n147u003k15qry7pvfmq2")!
    private let darkStyleURI = StyleURI(rawValue: "mapbox://styles/nmondollot/cmkea670800a701sdc5n67k3q")!
    
    private var currentStyleURI: StyleURI {
        traitCollection.userInterfaceStyle == .dark ? darkStyleURI : lightStyleURI
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let cameraOptions = CameraOptions(
            center: CLLocationCoordinate2D(latitude: 48.3925623, longitude: 2.5968216),
            zoom: 10.2
        )
        
        let myMapInitOptions = MapInitOptions(
            cameraOptions: cameraOptions,
            styleURI: currentStyleURI
        )
        
        mapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let configuration = Puck2DConfiguration.makeDefault(showBearing: true)
        mapView.location.options.puckType = .puck2D(configuration)
        mapView.location.options.puckBearingEnabled = true
        
        mapView.gestures.options.pitchEnabled = false
        mapView.gestures.options.simultaneousRotateAndPinchZoomEnabled = false
        mapView.gestures.options.doubleTapToZoomInEnabled = false // prevents the delay for TapInteraction
        mapView.gestures.options.doubleTouchToZoomOutEnabled = false // prevents the delay for TapInteraction
        
        mapView.ornaments.options.scaleBar.visibility = .hidden
        
        mapView.ornaments.options.compass.position = .bottomLeft
        mapView.ornaments.options.compass.margins = CGPoint(x: 8, y: 40)
        
        mapView.ornaments.options.attributionButton.position = .bottomLeading
        mapView.ornaments.options.attributionButton.margins = CGPoint(x: -4, y: 6)
        mapView.ornaments.options.logo.margins = CGPoint(x: 36, y: 8)
        
        // Make attribution elements less noticeable
        mapView.ornaments.logoView.alpha = 0.5
        mapView.ornaments.attributionButton.alpha = 0.5
        
        // Wait for the map to load its style before adding data.
        mapView.mapboxMap.onStyleLoaded.observeNext { [weak self] _ in
            guard let self = self else { return }
            self.addSources()
            self.addLayers()
        }.store(in: &cancelables)
        
        mapView.mapboxMap.addInteraction(TapInteraction { context in
            self.findFeatures(tapPoint: context.point)
            return true
        })
        
        // Important
        // This callback is called on every rendering frame. Don’t use it to modify @State variables, it will lead to excessive body execution and higher CPU consumption.
        // https://docs.mapbox.com/ios/maps/api/11.0.0-rc.1-docc/documentation/mapboxmaps/map-swift.struct/oncamerachanged(action:)/
        mapView.mapboxMap.onCameraChanged
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return !self.flyinToSomething
            }
            .throttle(for: .milliseconds(100), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] event in
                guard let self = self else { return }
                
                self.inferAreaFromMap()
                self.inferClusterFromMap()
                self.delegate?.cameraChanged(state: mapView.mapboxMap.cameraState)
            }.store(in: &cancelables)
        
        self.view.addSubview(mapView)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Check if the user interface style has changed
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateMapStyle()
        }
    }
    
    private func updateMapStyle() {
        mapView.mapboxMap.loadStyle(currentStyleURI) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error loading style: \(error)")
                return
            }
            
            // Re-add sources and layers after style change
            self.addSources()
            self.addLayers()
        }
    }

    let problemsSourceLayerId = "problems-ayes3a" // name of the layer in the mapbox tileset
    
    func addSources() {
        var problems = VectorSource(id: "problems")
        problems.url = "mapbox://nmondollot.4xsv235p"
        problems.promoteId2 = .byLayer([problemsSourceLayerId: .constant("id")]) // needed to make Feature-State work
        
        var circuits = VectorSource(id: "circuits")
        circuits.url = "mapbox://nmondollot.11sumdgh"

        do {
            try self.mapView.mapboxMap.addSource(problems)
            try self.mapView.mapboxMap.addSource(circuits)
        }
        catch {
            print("Ran into an error adding the sources: \(error)")
        }
    }
    
    func addLayers() {
        var problemsLayer = CircleLayer(id: "problems", source: "problems")
        problemsLayer.sourceLayer = problemsSourceLayerId
        problemsLayer.minZoom = 15
        problemsLayer.filter = Exp(.match) {
            ["geometry-type"]
            ["Point"] // don't display boulders (stored in the tileset as LineStrings)
            true
            false
        }
        
        problemsLayer.circleRadius = .expression(
            Exp(.interpolate) {
                ["linear"]
                ["zoom"]
                15
                2
                18
                4
                22
                Exp(.switchCase) {
                    Exp(.boolean) {
                        Exp(.has) { "circuitNumber" }
                        false
                    }
                    16
                    10
                }
            }
        )
        
        problemsLayer.circleColor = circuitColorExp(attribute: "circuitColor")
        
        problemsLayer.circleStrokeWidth = .expression(
            Exp(.switchCase) {
                Exp(.boolean) {
                    Exp(.featureState) { "selected" }
                    false
                }
                3.0
                0.0
            }
        )
        
        problemsLayer.circleStrokeColor = .constant(StyleColor(UIColor(resource: .appGreen)))
        
        problemsLayer.circleSortKey = .expression(
            Exp(.switchCase) {
                Exp(.boolean) {
                    Exp(.has) { "circuitId" }
                    false
                }
                2
                1
            }
        )
        
        problemsLayer.circleEmissiveStrength = .constant(0.9)
        
        var problemsTextsLayer = SymbolLayer(id: "problems-texts", source: "problems")
        problemsTextsLayer.sourceLayer = problemsSourceLayerId
        problemsTextsLayer.minZoom = 19
        problemsTextsLayer.filter = Exp(.match) {
            ["geometry-type"]
            ["Point"]
            true
            false
        }
        
        problemsTextsLayer.textAllowOverlap = .constant(true)
        problemsTextsLayer.textField = .expression(
            Exp(.toString) {
                ["get", "circuitNumber"]
            }
        )
        
        problemsTextsLayer.textSize = .expression(
            Exp(.interpolate) {
                ["linear"]
                ["zoom"]
                19
                10
                22
                20
            }
        )
        
        problemsTextsLayer.textColor = .expression(
            Exp(.switchCase) {
                Exp(.match) {
                    ["get", "circuitColor"]
                    ["", "white"]
                    true
                    false
                }
                UIColor.black // TODO: less dark
                UIColor.white
            }
        )
        
        // ===========================
        
        var problemsNamesLayer = SymbolLayer(id: "problems-names", source: "problems")
        problemsNamesLayer.sourceLayer = problemsSourceLayerId
        problemsNamesLayer.minZoom = 15
        problemsNamesLayer.visibility = .constant(.none)
        problemsNamesLayer.filter = Exp(.match) {
            ["geometry-type"]
            ["Point"]
            true
            false
        }
        
        problemsNamesLayer.textField = .expression(
            Exp(.concat) {
                Exp(.toString) {
                    ["get", "name"]
                }
                " "
                Exp(.toString) {
                    ["get", "grade"]
                }
            }
        )
        
        problemsNamesLayer.textSize = .expression(
            Exp(.interpolate) {
                ["linear"]
                ["zoom"]
                15
                8
                20
                14
            }
        )
        
        problemsNamesLayer.textVariableAnchor = .constant([.bottom, .top, .right, .left])
        problemsNamesLayer.textRadialOffset = .expression(
            Exp(.interpolate) {
                ["linear"]
                ["zoom"]
                15
                1
                20
                1.5
            }
        )
        problemsNamesLayer.textHaloColor = .constant(.init(traitCollection.userInterfaceStyle == .dark ? .black : .white))
        problemsNamesLayer.textHaloWidth = .constant(1)
        problemsNamesLayer.textColor = .constant(.init(traitCollection.userInterfaceStyle == .dark ? .white : .black))
        
        problemsNamesLayer.textAllowOverlap = .constant(false)
        problemsNamesLayer.textOptional = .constant(true)
        problemsNamesLayer.textIgnorePlacement = .constant(false)
        
        problemsNamesLayer.symbolSortKey = .expression(
            Exp(.product) {
                Exp(.toNumber) {
                    Exp(.get) { "popularity" }
                }
                -1.0
            }
        )
        
        // (invisible) layer to prevent problem names from overlapping with the problem circles
        var problemsNamesAntioverlapLayer = SymbolLayer(id: "problems-names-antioverlap", source: "problems")
        problemsNamesAntioverlapLayer.sourceLayer = problemsSourceLayerId
        problemsNamesAntioverlapLayer.minZoom = 15
        problemsNamesAntioverlapLayer.visibility = .constant(.none)
        problemsNamesAntioverlapLayer.filter = Exp(.match) {
            ["geometry-type"]
            ["Point"]
            true
            false
        }
        
        problemsNamesAntioverlapLayer.iconImage = .constant(.name("circle-15"))
        problemsNamesAntioverlapLayer.iconSize = .expression(
            Exp(.interpolate) {
                ["linear"]
                ["zoom"]
                15
                0.2
                20
                1
            }
        )
        problemsNamesAntioverlapLayer.iconAllowOverlap = .constant(true)
        problemsNamesAntioverlapLayer.iconOpacity = .constant(0)
        
        // ===========================
        
        var circuitsLayer = LineLayer(id: "circuits", source: "circuits")
        circuitsLayer.sourceLayer = "circuits-9weff8"
        circuitsLayer.minZoom = 15
        circuitsLayer.lineWidth = .constant(2)
        circuitsLayer.lineDasharray = .constant([4,1])
        circuitsLayer.lineColor = circuitColorExp(attribute: "color")
        circuitsLayer.visibility = .constant(.none)
        circuitsLayer.lineEmissiveStrength = .constant(0.9)
        
        var circuitProblemsLayer = CircleLayer(id: "circuit-problems", source: "problems")
        circuitProblemsLayer.sourceLayer = problemsSourceLayerId
        circuitProblemsLayer.minZoom = 15
        circuitProblemsLayer.visibility = .constant(.none)
        
        circuitProblemsLayer.circleRadius = .expression(
            Exp(.interpolate) {
                ["linear"]
                ["zoom"]
                15
                2
                18
                10
                22
                16
            }
        )
        
        circuitProblemsLayer.circleEmissiveStrength = .constant(0.9)
        
        circuitProblemsLayer.circleColor = problemsLayer.circleColor
        circuitProblemsLayer.circleStrokeWidth = problemsLayer.circleStrokeWidth
        circuitProblemsLayer.circleStrokeColor = problemsLayer.circleStrokeColor
        
        var circuitProblemsTextsLayer = SymbolLayer(id: "circuit-problems-texts", source: "problems")
        circuitProblemsTextsLayer.sourceLayer = problemsSourceLayerId
        circuitProblemsTextsLayer.minZoom = 16
        circuitProblemsTextsLayer.visibility = .constant(.none)

        circuitProblemsTextsLayer.textAllowOverlap = .constant(true)
        circuitProblemsTextsLayer.textField = .expression(
            Exp(.toString) {
                ["get", "circuitNumber"]
            }
        )

        circuitProblemsTextsLayer.textSize = .expression(
            Exp(.interpolate) {
                ["linear"]
                ["zoom"]
                16
                8
                17
                10
                19
                16
                22
                20
            }
        )

        circuitProblemsTextsLayer.textColor = problemsTextsLayer.textColor
        
        // ===========================
        
        do {
            try self.mapView.mapboxMap.addLayer(problemsLayer) // TODO: use layerPosition like on the web?
            try self.mapView.mapboxMap.addLayer(problemsTextsLayer)
            
            try self.mapView.mapboxMap.addLayer(problemsNamesLayer)
            try self.mapView.mapboxMap.addLayer(problemsNamesAntioverlapLayer)
            
            try self.mapView.mapboxMap.addLayer(circuitsLayer)
            try self.mapView.mapboxMap.addLayer(circuitProblemsLayer)
            try self.mapView.mapboxMap.addLayer(circuitProblemsTextsLayer)
        }
        catch {
            print("Ran into an error adding the layers: \(error)")
        }
    }
    
    func circuitColorExp(attribute: String) -> Value<StyleColor> {
        .expression(
            Exp(.match) {
                Exp(.get) { attribute }
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
    }
    
    func findFeatures(tapPoint: CGPoint) {
        
        // =================================================
        // Careful: the order of the queries is important
        // =================================================
        
        mapView.mapboxMap.queryRenderedFeatures(
            with: tapPoint,
            options: RenderedQueryOptions(layerIds: ["areas", "areas-hulls"], filter: nil)) { [weak self] result in
                
                guard let self = self else { return }
                
                if self.mapView.mapboxMap.cameraState.zoom >= 15 { return }
                
                switch result {
                case .success(let queriedfeatures):
                    
                    if let feature = queriedfeatures.first?.queriedFeature.feature,
                       case .number(let id) = feature.properties?["areaId"],
                       case .string(let southWestLon) = feature.properties?["southWestLon"],
                       case .string(let southWestLat) = feature.properties?["southWestLat"],
                       case .string(let northEastLon) = feature.properties?["northEastLon"],
                       case .string(let northEastLat) = feature.properties?["northEastLat"]
                    {
                        let coords = coordinatesFrom(southWestLat: southWestLat, southWestLon: southWestLon, northEastLat: northEastLat, northEastLon: northEastLon)

                        if let cameraOptions = self.cameraOptionsFor(coords, minZoom: 15) {
                            self.flyTo(cameraOptions)
                            self.delegate?.selectArea(id: Int(id))
                        }
                    }
                case .failure(let error):
                    print("An error occurred: \(error.localizedDescription)")
                }
            }
        
        mapView.mapboxMap.queryRenderedFeatures(
            with: tapPoint,
            options: RenderedQueryOptions(layerIds: ["clusters"], filter: nil)) { [weak self] result in
                
                guard let self = self else { return }
                
                switch result {
                case .success(let queriedfeatures):
                    
                    if let feature = queriedfeatures.first?.queriedFeature.feature,
                       case .number(let id) = feature.properties?["clusterId"],
                       case .string(let southWestLon) = feature.properties?["southWestLon"],
                       case .string(let southWestLat) = feature.properties?["southWestLat"],
                       case .string(let northEastLon) = feature.properties?["northEastLon"],
                       case .string(let northEastLat) = feature.properties?["northEastLat"]
                    {
                        let coords = coordinatesFrom(southWestLat: southWestLat, southWestLon: southWestLon, northEastLat: northEastLat, northEastLon: northEastLon)

                        if let cameraOptions = self.cameraOptionsFor(coords) {
                            self.flyTo(cameraOptions)
                            self.delegate?.selectCluster(id: Int(id))
                        }
                    }
                case .failure(let error):
                    print("An error occurred: \(error.localizedDescription)")
                }
            }
        
        // hack to be able to zoom to a level where problems are tappable
        mapView.mapboxMap.queryRenderedFeatures(
            with: CGRect(x: tapPoint.x-16, y: tapPoint.y-16, width: 32, height: 32),
            options: RenderedQueryOptions(layerIds: ["boulders", "problems-names"], filter: nil)) { [weak self] result in
                
                guard let self = self else { return }
                
                switch result {
                case .success(let queriedfeatures):
                    
                    if(queriedfeatures.first?.queriedFeature.feature.geometry != nil) {
                        if self.mapView.mapboxMap.cameraState.zoom >= 15 && self.mapView.mapboxMap.cameraState.zoom < 19 {
                            let cameraOptions = CameraOptions(
                                center: self.mapView.mapboxMap.coordinate(for: tapPoint),
                                padding: self.safePadding,
                                zoom: 19
                            )
                            self.flyTo(cameraOptions)
                        }
                    }
                    
                case .failure(let error):
                    print("An error occurred: \(error.localizedDescription)")
                }
            }
        
        mapView.mapboxMap.queryRenderedFeatures(
            with: tapPoint,
            options: RenderedQueryOptions(layerIds: ["pois"], filter: nil)) { [weak self] result in
                
                guard let self = self else { return }
                
                switch result {
                case .success(let queriedfeatures):
                    
                    if let feature = queriedfeatures.first?.queriedFeature.feature,
                       case .string(let name) = feature.properties?["name"],
                       case .string(let googleUrl) = feature.properties?["googleUrl"],
                       case .string(let type) = feature.properties?["type"],
                       case .point(let point) = feature.geometry
                    {
                        if (self.mapView.mapboxMap.cameraState.zoom >= 12 && type == "trainstation") || (self.mapView.mapboxMap.cameraState.zoom >= 14) {
                            self.delegate?.selectPoi(name: name, location: point.coordinates, googleUrl: googleUrl)
                        }
                    }
                case .failure(let error):
                    print("An error occurred: \(error.localizedDescription)")
                }
            }
        
        
        mapView.mapboxMap.queryRenderedFeatures(
            with: CGRect(x: tapPoint.x-16, y: tapPoint.y-16, width: 32, height: 32), // we use rect to avoid a weird bug with dynamic circle radius not triggering taps
            options: RenderedQueryOptions(layerIds: ["problems", "problems-names"], filter: nil)) { [weak self] result in
                
                guard let self = self else { return }
                
                if self.mapView.mapboxMap.cameraState.zoom < 19 { return }
                
                switch result {
                case .success(let queriedfeatures):
                    
                    let sortedFeatures = getSortedFeaturesByDistance(from: tapPoint, for: queriedfeatures)
                    
                    let sortedProblems = sortedFeatures.compactMap { feature in
                        if case .number(let id) = feature.properties?["id"] {
                            return Int(id)
                        }
                        return nil
                    }.compactMap { Problem.load(id: $0) }
                    
                    if let first = sortedProblems.first {
                        self.delegate?.selectProblem(id: first.id)
                        self.setProblemAsSelected(problemFeatureId: String(first.id))
                        
                        // if problem is hidden by the bottom sheet
                        if tapPoint.y >= (self.mapView.bounds.height/2 - 40) {
                            if let feature = sortedFeatures.first, case .point(let point) = feature.geometry {
                                
                                let cameraOptions = CameraOptions(
                                    center: point.coordinates,
                                    padding: self.safePaddingForBottomSheet
                                )
                                self.easeTo(cameraOptions)
                            }
                        }
                    }
                    else {
                        // TODO: make it more explicit that this works only at a certain zoom level
                        self.unselectPreviousProblem()
                        self.delegate?.dismissProblemDetails()
                    }
                case .failure(let error):
                    print("An error occurred: \(error.localizedDescription)")
                }
            }
        
        // TODO: make this DRY with problems layer
        // Note: I already tried using the same query for both problems and circuit-problems layer, but taps work better with tapPoint than with a rect => I prefered to keep a tapPoint for circuit-problem
        // Careful: the order between problems and circuit problems is important!
        mapView.mapboxMap.queryRenderedFeatures(
            with: tapPoint,
            options: RenderedQueryOptions(layerIds: ["circuit-problems"], filter: nil)) { [weak self] result in
                
                guard let self = self else { return }
                
                if self.mapView.mapboxMap.cameraState.zoom < 19 { return }
                
                switch result {
                case .success(let queriedfeatures):
                    
                    if let feature = queriedfeatures.first?.queriedFeature.feature,
                       case .number(let id) = feature.properties?["id"],
                       case .point(let point) = feature.geometry
                    {
                        self.delegate?.selectProblem(id: Int(id))
                        self.setProblemAsSelected(problemFeatureId: String(Int(id)))
                        
                        // if problem is hidden by the bottom sheet
                        if tapPoint.y >= (self.mapView.bounds.height/2 - 40) {
                            
                            let cameraOptions = CameraOptions(
                                center: point.coordinates,
                                padding: self.safePaddingForBottomSheet
                            )
                            self.easeTo(cameraOptions)
                        }
                    }
                case .failure(let error):
                    print("An error occurred: \(error.localizedDescription)")
                }
            }
    }
    
    func inferAreaFromMap() {
        if(!flyinToSomething) {
            
            let zoom = Exp(.gt) {
                Exp(.zoom)
                14.5
            }
            
            let width = mapView.frame.width/4
            let rect = CGRect(x: mapView.center.x - width/2, y: mapView.center.y - width/2 + safePaddingYForAreaDetector, width: width, height: width)
            
            //            var debugView = UIView(frame: rect)
            //            debugView.backgroundColor = .red
            //            mapView.addSubview(debugView)
            
            mapView.mapboxMap.queryRenderedFeatures(
                with: rect,
                options: RenderedQueryOptions(layerIds: ["areas-hulls"], filter: zoom)) { [weak self] result in
                    
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let queriedfeatures):
                        
                        if let feature = queriedfeatures.first?.queriedFeature.feature,
                           case .number(let id) = feature.properties?["areaId"]
                        {
                            self.delegate?.selectArea(id: Int(id))
                        }
                    case .failure(_):
                        break
                    }
                }
            
            if(mapView.mapboxMap.cameraState.zoom < 14.5) {
                delegate?.unselectArea()
            }
        }
    }
    
    func inferClusterFromMap() {
        if(!flyinToSomething) {
            
            let zoom = Exp(.gte) {
                Exp(.zoom)
                12
            }
            
            let width = mapView.frame.width/4
            let rect = CGRect(x: mapView.center.x - width/2, y: mapView.center.y - width/2 + safePaddingYForAreaDetector, width: width, height: width)
            
//                                    var debugView = UIView(frame: rect)
//                                    debugView.backgroundColor = .blue
//                                    mapView.addSubview(debugView)
            
            mapView.mapboxMap.queryRenderedFeatures(
                with: rect,
                options: RenderedQueryOptions(layerIds: ["clusters-hulls"], filter: zoom)) { [weak self] result in
                    
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let queriedfeatures):
                        
                        if let feature = queriedfeatures.first?.queriedFeature.feature,
                           case .number(let id) = feature.properties?["clusterId"]
                        {
                            self.delegate?.selectCluster(id: Int(id))
                        }
                    case .failure(_):
                        break
                    }
                }
            
            
            if(mapView.mapboxMap.cameraState.zoom < 11) {
                delegate?.unselectCluster()
            }
        }
    }
    
    private var favorites: [Favorite] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            let fetchRequest = Favorite.fetchRequest()
            return try context.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    private var ticks: [Tick] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            let fetchRequest = Tick.fetchRequest()
            return try context.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    private var favoritesNotTicked: Set<Int> {
        Set(favorites.map{ Int($0.problemId) }).subtracting(ticks.map{ Int($0.problemId) })
    }

    func applyFilters(_ filters: Filters) {
        do {
            let gradeMin = filters.gradeRange?.min ?? Grade.min
            let gradeMax = filters.gradeRange?.max ?? Grade.max
            
            let gradesArray = (gradeMin...gradeMax).map{ $0.string }
            
            try ["problems", "problems-texts", "problems-names", "problems-names-antioverlap"].forEach { layerId in
                try mapView.mapboxMap.updateLayer(withId: layerId, type: CircleLayer.self) { layer in
                    let gradeFilter = Exp(.match) {
                        Exp(.get) { "grade" }
                        gradesArray
                        true
                        false
                    }
                    
                    let popularFilter = Exp(.get) { "featured" }
                    
                    let favoriteFilter = Exp(.inExpression) {
                        Exp(.get) { "id" }
                        favoritesNotTicked.map{Double($0)}
                    }
                    
                    let tickFilter = Exp(.inExpression) {
                        Exp(.get) { "id" }
                        ticks.map{Double($0.problemId)}
                    }
                    
                    layer.filter = Exp(.all) {
                        gradeFilter
                        filters.popular ? popularFilter : Exp(.literal) { true }
                        filters.favorite ? favoriteFilter : Exp(.literal) { true }
                        filters.ticked ? tickFilter : Exp(.literal) { true }
                    }
                }
            }
            
            try ["problems-names", "problems-names-antioverlap"].forEach { layerId in
                try mapView.mapboxMap.updateLayer(withId: layerId, type: SymbolLayer.self) { layer in
                    let visibility = (filters.popular || filters.favorite || filters.ticked) ? Visibility.visible : Visibility.none
                    layer.visibility = .constant(visibility)
                }
            }
 
        } catch {
            print("Ran into an error updating the layer: \(error)")
        }
    }
    
    func centerOnProblem(_ problem: Problem) {
        flyTo(CameraOptions(
            center: problem.coordinate,
            padding: safePaddingForBottomSheet,
            zoom: 20
        ))
    }
    
    func centerOnArea(_ area: Area) {
        let coords = [
            CLLocationCoordinate2D(latitude: area.southWestLat, longitude: area.southWestLon),
            CLLocationCoordinate2D(latitude: area.northEastLat, longitude: area.northEastLon)
        ]
        
        if let cameraOptions = self.cameraOptionsFor(coords, minZoom: 15) {
            flyTo(cameraOptions)
        }
    }
    
    func centerOnCurrentLocation() {
        if let location = mapView.location.latestLocation {
            
            let fontainebleauBounds = CoordinateBounds(
                southwest: CLLocationCoordinate2D(latitude: 48.241596, longitude: 2.3936456),
                northeast: CLLocationCoordinate2D(latitude: 48.5075073, longitude: 2.7616875)
            )
            
            let currentZoomLevel = mapView.mapboxMap.cameraState.zoom
            
            if fontainebleauBounds.contains(forPoint: location.coordinate, wrappedCoordinates: false) {
                let cameraOptions = CameraOptions(
                    center: location.coordinate,
                    padding: safePadding,
                    zoom: max(currentZoomLevel, 17)
                )
                
                flyTo(cameraOptions)
            }
            else {
                let bounds = fontainebleauBounds.extend(forPoint: location.coordinate)
                
                let coords = [bounds.southwest, bounds.northeast]
                
                if let cameraOptions = self.cameraOptionsFor(coords) {
                    flyTo(cameraOptions)
                }
            }
        }
    }
    
    func centerOnCircuit(_ circuit: Circuit) {
        let coords = [
            CLLocationCoordinate2D(latitude: circuit.southWestLat, longitude: circuit.southWestLon),
            CLLocationCoordinate2D(latitude: circuit.northEastLat, longitude: circuit.northEastLon)
        ]
        
        if let cameraOptions = self.cameraOptionsFor(coords, minZoom: 15) {
            flyTo(cameraOptions)
        }
    }
    
    func centerOnBoulderCoordinates(_ coordinates: [CLLocationCoordinate2D]) {
        guard !coordinates.isEmpty else { return }
        
        let padding = safePaddingForBoulder
        let paddedRect = CGRect(
            x: padding.left,
            y: padding.top,
            width: view.bounds.width - padding.left - padding.right,
            height: view.bounds.height - padding.top - padding.bottom
        )
        
        // Check if all coordinates are already visible within the padded area
        let allVisible = coordinates.allSatisfy { coord in
            let point = mapView.mapboxMap.point(for: coord)
            return paddedRect.contains(point)
        }
        
        guard !allVisible else { return }
        
        let currentZoom = mapView.mapboxMap.cameraState.zoom
        
        // Fit all coordinates within the padded area, keeping the current zoom
        // unless it's too tight (maxZoom caps the zoom so it only pans or zooms out).
        if let fittedCamera = try? mapView.mapboxMap.camera(
            for: coordinates,
            camera: CameraOptions(padding: UIEdgeInsets(), bearing: 0, pitch: 0),
            coordinatesPadding: padding,
            maxZoom: currentZoom,
            offset: nil
        ) {
            flyTo(fittedCamera)
        }
    }
    
    func setCircuitAsSelected(circuit: Circuit) {
        do {
            try ["circuits"].forEach { layerId in
                try mapView.mapboxMap.updateLayer(withId: layerId, type: LineLayer.self) { layer in
                    layer.filter = Exp(.match) {
                        Exp(.get) { "id" }
                        [Double(circuit.id)]
                        true
                        false
                    }
                    layer.visibility = .constant(.visible)
                }
            }
            
            try ["circuit-problems", "circuit-problems-texts"].forEach { layerId in
                try mapView.mapboxMap.updateLayer(withId: layerId, type: CircleLayer.self) { layer in
                    layer.filter = Exp(.match) {
                        Exp(.get) { "circuitId" }
                        [Double(circuit.id)]
                        true
                        false
                    }
                    layer.visibility = .constant(.visible)
                }
            }
 
        } catch {
            print("Ran into an error updating the layer: \(error)")
        }
    }
    
    func unselectCircuit() {
        do {
            try ["circuits"].forEach { layerId in
                try mapView.mapboxMap.updateLayer(withId: layerId, type: LineLayer.self) { layer in
                    layer.visibility = .constant(.none)
                }
            }
            
            try ["circuit-problems", "circuit-problems-texts"].forEach { layerId in
                try mapView.mapboxMap.updateLayer(withId: layerId, type: CircleLayer.self) { layer in
                    layer.visibility = .constant(.none)
                }
            }
 
        } catch {
            print("Ran into an error updating the layer: \(error)")
        }
    }
    
    private var previouslyTappedProblemId: String = ""
    private var previouslySelectedTopoIds: [String] = []
    /// Pre-cached problem IDs for the currently selected topo.
    /// Set from MapboxView using cached data – avoids SQLite in the hot path.
    var selectedTopoProblemIds: [String] = []
    
    func setProblemAsSelected(problemFeatureId: String) {
        // Unselect previously selected topo problems
        unselectPreviousTopoProblems()
        
        self.mapView.mapboxMap.setFeatureState(sourceId: "problems",
                                               sourceLayerId: problemsSourceLayerId,
                                               featureId: problemFeatureId,
                                               state: ["selected": true]) { result in
            
        }
        
        if problemFeatureId != self.previouslyTappedProblemId {
            unselectPreviousProblem()
        }
        
        self.previouslyTappedProblemId = problemFeatureId
        
        // Also select all sibling problems on the same topo (using pre-cached IDs)
        if !selectedTopoProblemIds.isEmpty {
            var selectedIds: [String] = []
            
            for featureId in selectedTopoProblemIds {
                if featureId != problemFeatureId {
                    self.mapView.mapboxMap.setFeatureState(sourceId: "problems",
                                                           sourceLayerId: problemsSourceLayerId,
                                                           featureId: featureId,
                                                           state: ["selected": true]) { result in
                    }
                    selectedIds.append(featureId)
                }
            }
            
            previouslySelectedTopoIds = selectedIds
        }
    }
    
    func unselectPreviousProblem() {
        if(self.previouslyTappedProblemId != "") {
            self.mapView.mapboxMap.setFeatureState(sourceId: "problems",
                                                   sourceLayerId: problemsSourceLayerId,
                                                   featureId: self.previouslyTappedProblemId,
                                                   state: ["selected": false]) { result in
                
            }
        }
    }
    
    private func unselectPreviousTopoProblems() {
        for featureId in previouslySelectedTopoIds {
            self.mapView.mapboxMap.setFeatureState(sourceId: "problems",
                                                   sourceLayerId: problemsSourceLayerId,
                                                   featureId: featureId,
                                                   state: ["selected": false]) { result in
            }
        }
        previouslySelectedTopoIds = []
    }
    
    func flyTo(_ cameraOptions: CameraOptions) {
        flyinToSomething = true
        
        mapView.camera.fly(to: cameraOptions, duration: flyinDuration) { _ in
            self.flyinToSomething = false
            
            // hack to make sure we detect the right cluster and area after the fly animation is done
            // we do this because sometimes the area and/or cluster are unselected by mistake because the inferArea/inferCluster funcs are called during a flying animation
            // we can probably remove it when we move to MapboxMap.isAnimationInProgress in v11
            self.triggerMapDetectors()
        }
    }
    
    func easeTo(_ cameraOptions: CameraOptions) {
        flyinToSomething = true
        mapView.camera.ease(to: cameraOptions, duration: flyinDuration) { _ in
            self.flyinToSomething = false
            
            // TODO: use the same hack as flyTo() ?
        }
    }
    
    func triggerMapDetectors() {
        // hack to make sure we detect the right cluster and area after the flying animation is done
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.inferAreaFromMap()
            self.inferClusterFromMap()
        }
    }
    
    var flyinToSomething = false // TODO: replace with MapboxMap.isAnimationInProgress in v11 (probably more reliable)
    let flyinDuration = 0.5
    let safePadding = UIEdgeInsets(top: 180, left: 20, bottom: 180, right: 20)
    var safePaddingForBottomSheet : UIEdgeInsets {
        UIEdgeInsets(top: 20, left: 0, bottom: view.bounds.height/2 + 40, right: 0)
    }
    var safePaddingForBoulder: UIEdgeInsets {
        UIEdgeInsets(top: 40, left: 20, bottom: view.bounds.height/2 + 40, right: 20)
    }
    let safePaddingYForAreaDetector : CGFloat = 30 // TODO: check if it works
    
    private func coordinatesFrom(southWestLat: String, southWestLon: String, northEastLat: String, northEastLon: String) -> [CLLocationCoordinate2D] {
        if let southWestLat = Double(southWestLat), let southWestLon = Double(southWestLon), let northEastLat = Double(northEastLat), let northEastLon = Double(northEastLon) {
            
            return [
                CLLocationCoordinate2D(latitude: southWestLat, longitude: southWestLon),
                CLLocationCoordinate2D(latitude: northEastLat, longitude: northEastLon),
            ]
        }
        
        return []
    }
    
    private func cameraOptionsFor(_ coordinates: [CLLocationCoordinate2D], minZoom: CGFloat? = nil) -> CameraOptions? {
        if var cameraOptions = try? self.mapView.mapboxMap.camera(
            for: coordinates,
            camera: CameraOptions(padding: UIEdgeInsets(), bearing: 0, pitch: 0),
            coordinatesPadding: self.safePadding,
            maxZoom: nil,
            offset: nil) {
            
            if let minZoom = minZoom {
                cameraOptions.zoom = max(minZoom, cameraOptions.zoom ?? 0)
            }
            
            return cameraOptions
        }
        
        return nil
    }
    
    private func getSortedFeaturesByDistance(from tapPoint: CGPoint, for features: [QueriedRenderedFeature]) -> [Feature] {
        let tapCoord = mapView.mapboxMap.coordinate(for: tapPoint)
        let tapLoc = CLLocation(latitude: tapCoord.latitude, longitude: tapCoord.longitude)
        
        let withDistances = features.compactMap { qf -> (QueriedRenderedFeature, CLLocationDistance)? in
            guard case let .point(ptCoords) = qf.queriedFeature.feature.geometry else { 
                return nil 
            }
            
            let featureLoc = CLLocation(
                latitude: ptCoords.coordinates.latitude, 
                longitude: ptCoords.coordinates.longitude
            )
            let distance = featureLoc.distance(from: tapLoc)
            return (qf, distance)
        }
        
        return withDistances.sorted { $0.1 < $1.1 }.map { $0.0.queriedFeature.feature }
    }
}

import CoreLocation

protocol MapBoxViewDelegate {
    func selectProblem(id: Int)
    func selectPoi(name: String, location: CLLocationCoordinate2D, googleUrl: String)
    func selectArea(id: Int)
    func selectCluster(id: Int)
    func unselectArea()
    func unselectCluster()
    func unselectCircuit()
    func cameraChanged(state: CameraState)
    func dismissProblemDetails()
}
