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
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let accessToken = Bundle.main.object(forInfoDictionaryKey: "MBXAccessToken") as? String

        if accessToken == nil {
            print("access token not found in Info.plist")
        }
        
        let myResourceOptions = ResourceOptions(accessToken: accessToken ?? "")
        
        let cameraOptions = CameraOptions(
            center: CLLocationCoordinate2D(latitude: 48.3925623, longitude: 2.5968216),
            zoom: 10.2
        )
        
        let myMapInitOptions = MapInitOptions(
            resourceOptions: myResourceOptions,
            cameraOptions: cameraOptions,
            styleURI: StyleURI(rawValue: "mapbox://styles/nmondollot/cl95n147u003k15qry7pvfmq2")
        )
        
        mapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let configuration = Puck2DConfiguration.makeDefault(showBearing: true)
        mapView.location.options.puckType = .puck2D(configuration)
        
        mapView.gestures.options.pitchEnabled = false
        mapView.gestures.options.simultaneousRotateAndPinchZoomEnabled = false
        
        mapView.ornaments.options.scaleBar.visibility = .hidden
        
        mapView.ornaments.options.compass.position = .bottomLeft
        mapView.ornaments.options.compass.margins = CGPoint(x: 8, y: 40)
        
        mapView.ornaments.options.attributionButton.position = .bottomLeading
        mapView.ornaments.options.attributionButton.margins = CGPoint(x: -4, y: 6)
        mapView.ornaments.options.logo.margins = CGPoint(x: 36, y: 8)
        
        // Wait for the map to load its style before adding data.
        mapView.mapboxMap.onNext(event: .mapLoaded) { [self] _ in
            self.addSources()
            self.addLayers()
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.findFeatures))
            self.mapView.addGestureRecognizer(tapGesture)
        }
        
        mapView.mapboxMap.onEvery(event: .cameraChanged) { [self] _ in
            // Camera movement check is throttled for performance reason (especially during flying animations)
            let cameraCheckThrottleRate = DispatchTimeInterval.milliseconds(100)
            guard lastCameraCheck == nil || lastCameraCheck!.advanced(by: cameraCheckThrottleRate) <= DispatchTime.now() else {
                return
            }
            
            lastCameraCheck = DispatchTime.now()
            
            self.inferAreaFromMap()
            self.inferClusterFromMap()
            self.inferVisibleAreasFromMap()
            
            if(!flyinToSomething) {
                self.delegate?.cameraChanged()
            }
        }
        
        self.view.addSubview(mapView)
    }
    var lastCameraCheck: DispatchTime?

    let problemsSourceLayerId = "problems-ayes3a" // name of the layer in the mapbox tileset
    
    func addSources() {
        var problems = VectorSource()
        problems.url = "mapbox://nmondollot.4xsv235p"
        problems.promoteId = .string("id") // needed to make Feature-State work
        
        var circuits = VectorSource()
        circuits.url = "mapbox://nmondollot.11sumdgh"
        
        var clusters = VectorSource()
        clusters.url = "mapbox://nmondollot.27j044u9"

        do {
            try self.mapView.mapboxMap.style.addSource(problems, id: "problems")
            try self.mapView.mapboxMap.style.addSource(circuits, id: "circuits")
            try self.mapView.mapboxMap.style.addSource(clusters, id: "clusters-v2")
        }
        catch {
            print("Ran into an error adding the sources: \(error)")
        }
    }
    
    func addLayers() {
        var clustersLayer = FillLayer(id: "clusters-v2")  // CircleLayer(id: "clusters-v2")
        clustersLayer.source = "clusters-v2"
        clustersLayer.sourceLayer = "clusters-v2-9vxoh5"
        clustersLayer.fillOpacity = .constant(0)
        clustersLayer.minZoom = 1
        
        
        var problemsLayer = CircleLayer(id: "problems")
        problemsLayer.source = "problems"
        problemsLayer.sourceLayer = problemsSourceLayerId
        problemsLayer.minZoom = 15
        problemsLayer.filter = Expression(.match) {
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
        
        var problemsTextsLayer = SymbolLayer(id: "problems-texts")
        problemsTextsLayer.source = "problems"
        problemsTextsLayer.sourceLayer = problemsSourceLayerId
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
            Expression(.switchCase) {
                Expression(.match) {
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
        
        var problemsNamesLayer = SymbolLayer(id: "problems-names")
        problemsNamesLayer.source = "problems"
        problemsNamesLayer.sourceLayer = problemsSourceLayerId
        problemsNamesLayer.minZoom = 15
        problemsNamesLayer.visibility = .constant(.none)
        problemsNamesLayer.filter = Expression(.match) {
            ["geometry-type"]
            ["Point"]
            true
            false
        }
        
        problemsNamesLayer.textField = .expression(
            Exp(.concat) {
                Expression(.toString) {
                    ["get", "name"]
                }
                " "
                Expression(.toString) {
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
        problemsNamesLayer.textHaloColor = .constant(.init(.white))
        problemsNamesLayer.textHaloWidth = .constant(1)
        
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
        var problemsNamesAntioverlapLayer = SymbolLayer(id: "problems-names-antioverlap")
        problemsNamesAntioverlapLayer.source = "problems"
        problemsNamesAntioverlapLayer.sourceLayer = problemsSourceLayerId
        problemsNamesAntioverlapLayer.minZoom = 15
        problemsNamesAntioverlapLayer.visibility = .constant(.none)
        problemsNamesAntioverlapLayer.filter = Expression(.match) {
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
        
        var circuitsLayer = LineLayer(id: "circuits")
        circuitsLayer.source = "circuits"
        circuitsLayer.sourceLayer = "circuits-9weff8"
        circuitsLayer.minZoom = 15
        circuitsLayer.lineWidth = .constant(2)
        circuitsLayer.lineDasharray = .constant([4,1])
        circuitsLayer.lineColor = circuitColorExp(attribute: "color")
        circuitsLayer.visibility = .constant(.none)
        
        var circuitProblemsLayer = CircleLayer(id: "circuit-problems")
        circuitProblemsLayer.source = "problems"
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
        
        circuitProblemsLayer.circleColor = problemsLayer.circleColor
        circuitProblemsLayer.circleStrokeWidth = problemsLayer.circleStrokeWidth
        circuitProblemsLayer.circleStrokeColor = problemsLayer.circleStrokeColor
        
        var circuitProblemsTextsLayer = SymbolLayer(id: "circuit-problems-texts")
        circuitProblemsTextsLayer.source = "problems"
        circuitProblemsTextsLayer.sourceLayer = problemsSourceLayerId
        circuitProblemsTextsLayer.minZoom = 16
        circuitProblemsTextsLayer.visibility = .constant(.none)

        circuitProblemsTextsLayer.textAllowOverlap = .constant(true)
        circuitProblemsTextsLayer.textField = .expression(
            Expression(.toString) {
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
        
        do {
            try self.mapView.mapboxMap.style.addLayer(clustersLayer)
            
            try self.mapView.mapboxMap.style.addLayer(problemsLayer) // TODO: use layerPosition like on the web?
            try self.mapView.mapboxMap.style.addLayer(problemsTextsLayer)
            
            try self.mapView.mapboxMap.style.addLayer(problemsNamesLayer)
            try self.mapView.mapboxMap.style.addLayer(problemsNamesAntioverlapLayer)
            
            try self.mapView.mapboxMap.style.addLayer(circuitsLayer)
            try self.mapView.mapboxMap.style.addLayer(circuitProblemsLayer)
            try self.mapView.mapboxMap.style.addLayer(circuitProblemsTextsLayer)
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
    
    @objc public func findFeatures(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: mapView)
        
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
                    
                    if let feature = queriedfeatures.first?.feature,
                       case .number(let id) = feature.properties?["areaId"],
                       case .string(let southWestLon) = feature.properties?["southWestLon"],
                       case .string(let southWestLat) = feature.properties?["southWestLat"],
                       case .string(let northEastLon) = feature.properties?["northEastLon"],
                       case .string(let northEastLat) = feature.properties?["northEastLat"]
                    {
                        let bounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: Double(southWestLat) ?? 0, longitude: Double(southWestLon) ?? 0),
                                                      northeast: CLLocationCoordinate2D(latitude: Double(northEastLat) ?? 0, longitude: Double(northEastLon) ?? 0))
                        
                        var cameraOptions = self.mapView.mapboxMap.camera(for: bounds, padding: self.safePadding, bearing: 0, pitch: 0)
                        cameraOptions.zoom = max(15, cameraOptions.zoom ?? 0)
                        
                        self.flyTo(cameraOptions)
                        
                        self.delegate?.selectArea(id: Int(id))
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
                    
                    if let feature = queriedfeatures.first?.feature,
                       case .string(let southWestLon) = feature.properties?["southWestLon"],
                       case .string(let southWestLat) = feature.properties?["southWestLat"],
                       case .string(let northEastLon) = feature.properties?["northEastLon"],
                       case .string(let northEastLat) = feature.properties?["northEastLat"]
                    {
                        let bounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: Double(southWestLat) ?? 0, longitude: Double(southWestLon) ?? 0),
                                                      northeast: CLLocationCoordinate2D(latitude: Double(northEastLat) ?? 0, longitude: Double(northEastLon) ?? 0))
                        
                        let cameraOptions = self.mapView.mapboxMap.camera(for: bounds, padding: self.safePadding, bearing: 0, pitch: 0)
                        
                        self.flyTo(cameraOptions)
                        
                        // TODO: select the cluster
//                        self.delegate?.selectCluster(id: )
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
                    
                    if(queriedfeatures.first?.feature.geometry != nil) {
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
                    
                    if let feature = queriedfeatures.first?.feature,
                       case .string(let name) = feature.properties?["name"],
                       case .string(let googleUrl) = feature.properties?["googleUrl"],
                       case .point(let point) = feature.geometry
                    {
                        if self.mapView.mapboxMap.cameraState.zoom >= 12 {
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
                    
                    if let feature = queriedfeatures.first?.feature,
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
                    
                    if let feature = queriedfeatures.first?.feature,
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
            
            let zoom = Expression(.gt) {
                Expression(.zoom)
                14.5
            }
            
            let width = mapView.frame.width/4
            let rect = CGRect(x: mapView.center.x - width/2, y: mapView.center.y - width/2, width: width, height: width)
            
            //            var debugView = UIView(frame: rect)
            //            debugView.backgroundColor = .red
            //            mapView.addSubview(debugView)
            
            mapView.mapboxMap.queryRenderedFeatures(
                with: rect,
                options: RenderedQueryOptions(layerIds: ["areas-hulls"], filter: zoom)) { [weak self] result in
                    
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let queriedfeatures):
                        
                        if let feature = queriedfeatures.first?.feature,
                           case .number(let id) = feature.properties?["areaId"]
                        {
                            self.delegate?.selectArea(id: Int(id))
                        }
                    case .failure(_):
                        break
                    }
                }
            
            
            if(mapView.mapboxMap.cameraState.zoom < 15) {
                delegate?.unselectArea()
            }
        }
    }
    
    func inferClusterFromMap() {
        if(!flyinToSomething) {
            
            let zoom = Expression(.gt) {
                Expression(.zoom)
                12
            }
            
            let width = mapView.frame.width/4
            let rect = CGRect(x: mapView.center.x - width/2, y: mapView.center.y - width/2, width: width, height: width)
            
            //                        var debugView = UIView(frame: rect)
            //                        debugView.backgroundColor = .red
            //                        mapView.addSubview(debugView)
            
            mapView.mapboxMap.queryRenderedFeatures(
                with: rect,
                options: RenderedQueryOptions(layerIds: ["clusters-v2"], filter: zoom)) { [weak self] result in
                    
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let queriedfeatures):
                        
                        if let feature = queriedfeatures.first?.feature,
                           case .number(let id) = feature.properties?["clusterId"]
                        {
                            self.delegate?.selectCluster(id: Int(id))
                        }
                    case .failure(_):
                        break
                    }
                }
            
            
            if(mapView.mapboxMap.cameraState.zoom < 12) {
                delegate?.unselectCluster()
            }
        }
    }
    
    func inferVisibleAreasFromMap() {
        if(!flyinToSomething) {
            
//            let zoom = Expression(.lt) {
//                Expression(.zoom)
//                14.5
//            }
            
            let width = mapView.frame.width * 0.9 // FIXME: check height too
            let rect = CGRect(x: mapView.center.x - width/2, y: mapView.center.y - width/2, width: width, height: width)
            
            var debugView = UIView(frame: rect)
            
//            debugView.layer.borderColor = UIColor.blue.cgColor
//            debugView.layer.borderWidth = 2
//            mapView.addSubview(debugView)
            
            mapView.mapboxMap.queryRenderedFeatures(
                with: rect,
                options: RenderedQueryOptions(layerIds: ["areas-hulls"], filter: nil)) { [weak self] result in
                    
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let queriedfeatures):
                        
                        let areas = queriedfeatures.map { f in
                            if case .number(let id) = f.feature.properties?["areaId"]
                            {
                                return Area.load(id: Int(id))
                            }
                            
                            return nil
                        }.compactMap{$0}
                        
                        self.delegate?.setVisibleAreas(areas)
                        
                    case .failure(_):
                        break
                    }
                }
            
            
            if(mapView.mapboxMap.cameraState.zoom < 10) {
                delegate?.unselectArea()
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
                try mapView.mapboxMap.style.updateLayer(withId: layerId, type: CircleLayer.self) { layer in
                    let gradeFilter = Expression(.match) {
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
                try mapView.mapboxMap.style.updateLayer(withId: layerId, type: SymbolLayer.self) { layer in
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
        let bounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: area.southWestLat, longitude: area.southWestLon),
                                      northeast: CLLocationCoordinate2D(latitude: area.northEastLat, longitude: area.northEastLon))

        
        var cameraOptions = mapView.mapboxMap.camera(for: bounds, padding: safePadding, bearing: 0, pitch: 0)
        cameraOptions.zoom = max(15, cameraOptions.zoom ?? 0)
        
        flyTo(cameraOptions)
    }
    
    func centerOnCurrentLocation() {
        if let location = mapView.location.latestLocation {
            
            let fontainebleauBounds = CoordinateBounds(
                southwest: CLLocationCoordinate2D(latitude: 48.241596, longitude: 2.3936456),
                northeast: CLLocationCoordinate2D(latitude: 48.5075073, longitude: 2.7616875)
            )
            
            if fontainebleauBounds.contains(forPoint: location.coordinate, wrappedCoordinates: false) {
                let cameraOptions = CameraOptions(
                    center: location.coordinate,
                    padding: safePadding,
                    zoom: 17
                )
                
                flyTo(cameraOptions)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + flyinDuration + 0.1) { // make sure the fly animation is over
                    self.inferAreaFromMap()
                    self.inferClusterFromMap()
                    self.inferVisibleAreasFromMap()
                    // TODO: what if map is slow to load? we should infer again after it's loaded
                }
            }
            else {
                let cameraOptions = mapView.mapboxMap.camera(
                    for: fontainebleauBounds.extend(forPoint: location.coordinate),
                    padding: safePadding,
                    bearing: 0,
                    pitch: 0
                )
                
                flyTo(cameraOptions)
            }
        }
    }
    
    func centerOnCircuit(_ circuit: Circuit) {
        let circuitBounds = CoordinateBounds(
            southwest: CLLocationCoordinate2D(latitude: circuit.southWestLat, longitude: circuit.southWestLon),
            northeast: CLLocationCoordinate2D(latitude: circuit.northEastLat, longitude: circuit.northEastLon)
        )
        
        var cameraOptions = mapView.mapboxMap.camera(
            for: circuitBounds,
            padding: safePadding,
            bearing: 0,
            pitch: 0
        )
        cameraOptions.zoom = max(15, cameraOptions.zoom ?? 0)
        
        flyTo(cameraOptions)
    }
    
    func setCircuitAsSelected(circuit: Circuit) {
        do {
            try ["circuits"].forEach { layerId in
                try mapView.mapboxMap.style.updateLayer(withId: layerId, type: LineLayer.self) { layer in
                    layer.filter = Expression(.match) {
                        Exp(.get) { "id" }
                        [Double(circuit.id)]
                        true
                        false
                    }
                    layer.visibility = .constant(.visible)
                }
            }
            
            try ["circuit-problems", "circuit-problems-texts"].forEach { layerId in
                try mapView.mapboxMap.style.updateLayer(withId: layerId, type: CircleLayer.self) { layer in
                    layer.filter = Expression(.match) {
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
                try mapView.mapboxMap.style.updateLayer(withId: layerId, type: LineLayer.self) { layer in
                    layer.visibility = .constant(.none)
                }
            }
            
            try ["circuit-problems", "circuit-problems-texts"].forEach { layerId in
                try mapView.mapboxMap.style.updateLayer(withId: layerId, type: CircleLayer.self) { layer in
                    layer.visibility = .constant(.none)
                }
            }
 
        } catch {
            print("Ran into an error updating the layer: \(error)")
        }
    }
    
    private var previouslyTappedProblemId: String = ""
    
    func setProblemAsSelected(problemFeatureId: String) {
        self.mapView.mapboxMap.setFeatureState(sourceId: "problems",
                                               sourceLayerId: problemsSourceLayerId,
                                               featureId: problemFeatureId,
                                               state: ["selected": true])
        
        if problemFeatureId != self.previouslyTappedProblemId {
            unselectPreviousProblem()
        }
        
        self.previouslyTappedProblemId = problemFeatureId
    }
    
    func unselectPreviousProblem() {
        if(self.previouslyTappedProblemId != "") {
            self.mapView.mapboxMap.setFeatureState(sourceId: "problems",
                                                   sourceLayerId: problemsSourceLayerId,
                                                   featureId: self.previouslyTappedProblemId,
                                                   state: ["selected": false])
        }
    }
    
    func flyTo(_ cameraOptions: CameraOptions) {
        flyinToSomething = true
        mapView.camera.fly(to: cameraOptions, duration: flyinDuration) { _ in self.flyinToSomething = false }
    }
    
    func easeTo(_ cameraOptions: CameraOptions) {
        flyinToSomething = true
        mapView.camera.ease(to: cameraOptions, duration: flyinDuration) { _ in self.flyinToSomething = false }
    }
    
    var flyinToSomething = false
    let flyinDuration = 0.5
    let safePadding = UIEdgeInsets(top: 180, left: 20, bottom: 80, right: 20)
    var safePaddingForBottomSheet : UIEdgeInsets {
        UIEdgeInsets(top: 60, left: 0, bottom: view.bounds.height/2, right: 0)
    }
}

import CoreLocation

protocol MapBoxViewDelegate {
    func selectProblem(id: Int)
    func selectPoi(name: String, location: CLLocationCoordinate2D, googleUrl: String)
    func selectArea(id: Int)
    func selectCluster(id: Int)
    func setVisibleAreas(_ areas: [Area])
    func unselectArea()
    func unselectCluster()
    func unselectCircuit()
    func cameraChanged()
    func dismissProblemDetails()
}
