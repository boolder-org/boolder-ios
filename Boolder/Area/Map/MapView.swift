//
//  MapView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import MapKit
import SwiftUI
import CoreLocation

// heavily inspired from https://www.hackingwithswift.com/books/ios-swiftui/advanced-mkmapview-with-swiftui

struct MapView: UIViewRepresentable {
    @EnvironmentObject var dataStore: DataStore
    @Binding var selectedProblem: Problem
    @Binding var presentProblemDetails: Bool
    @Binding var selectedPoi: Poi?
    @Binding var presentPoiActionSheet: Bool
    @Binding var centerOnCurrentLocationCount: Int
    @Binding var centerOnProblem: Problem?
    @Binding var centerOnProblemCount: Int
    
    var mapView = MKMapView() // FIXME: put in makeUIView() ?
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        
        mapView.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 10, maxCenterCoordinateDistance: 20_000_000), animated: true)
        
        let initialLocation = CLLocation(latitude: 48.461788, longitude: 2.663394)
        let regionRadius: CLLocationDistance = 7_000
        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: false)
        
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = false
        
        mapView.register(ProblemAnnotationView.self, forAnnotationViewWithReuseIdentifier: ProblemAnnotationView.ReuseID)
        mapView.register(PoiAnnotationView.self, forAnnotationViewWithReuseIdentifier: PoiAnnotationView.ReuseID)
        
//        context.coordinator.deviceDidRotate()
        
        return mapView
    }
    
    // FIXME: is there a cleaner way to trigger a UI refresh?
    // current approach: - compare a hash of objects (before/after)
    //                   - increment a counter
    // which is a bit ugly :(
    func updateUIView(_ mapView: MKMapView, context: Context) {

        // remove & add annotations back only if needed to avoid flickering
        
        let previousAnnotationsIds: [Int] = mapView.annotations.compactMap{ annotation in
            if let annotation = annotation as? ProblemAnnotation {
                return annotation.problem.id
            } else {
                return nil
            }
        }
        
        let newAnnotationsIds: [Int] = dataStore.problems.map{ $0.id! }
        
        let previousHash = previousAnnotationsIds.sorted().map{String($0)}.joined(separator: "-")
        let newHash = newAnnotationsIds.sorted().map{String($0)}.joined(separator: "-")
        
        if previousHash != newHash {
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)
            mapView.addAnnotations(self.dataStore.problems.map{$0.annotation})
            mapView.addAnnotations(self.dataStore.pois.compactMap{$0.annotation})
            mapView.addOverlays(self.dataStore.overlays)
        }
        
        for annotation in mapView.annotations {
            if let annotation = annotation as? ProblemAnnotation {
                if let annotationView = mapView.view(for: annotation) as? ProblemAnnotationView {
                    annotationView.refreshUI()
                }
            }
        }
        
        // zoom to new region if needed
        
        let changedCircuit = context.coordinator.lastCircuit != dataStore.filters.circuit && dataStore.filters.circuit != nil
        context.coordinator.lastCircuit = dataStore.filters.circuit
        
        let changedArea = context.coordinator.lastArea != dataStore.areaId
        context.coordinator.lastArea = dataStore.areaId
        
        if changedCircuit || changedArea {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let rect = context.coordinator.rectThatFits(self.dataStore.problems.map{$0.annotation}+self.dataStore.pois.map{$0.annotation})
                mapView.setVisibleMapRect(rect, animated: false)
            }
        }
        
        // zoom on current location
        
        if centerOnCurrentLocationCount > context.coordinator.lastCenterOnCurrentLocationCount {
            context.coordinator.locate()
            context.coordinator.lastCenterOnCurrentLocationCount = centerOnCurrentLocationCount
        }
        
        // zoom on problem
        
        if centerOnProblemCount > context.coordinator.lastCenterOnProblemCount {
            if let problem = centerOnProblem {
                mapView.setCamera(MKMapCamera(lookingAtCenter: problem.coordinate, fromDistance: 50, pitch: 0, heading: mapView.camera.heading), animated: true)
                
                context.coordinator.lastCenterOnProblemCount = centerOnProblemCount
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: Coordinator
    
    class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        enum ZoomLevel: Int {
            case zoomedIn
            case zoomedIntermediate
            case zoomedOut
        }
        
        var parent: MapView
        var lastCircuit: Circuit.CircuitColor? = nil
        var lastArea: Int? = nil
        var locationManager = CLLocationManager()
        var lastLocation: CLLocation?
        var lastLocationAccuracy: CLLocationAccuracy?
        var lastHeadingAccuracy: CLLocationDirectionAccuracy?
        var lastCenterOnCurrentLocationCount = 0
        var lastCenterOnProblemCount = 0
        
        private var zoomLevel: ZoomLevel = .zoomedOut {
            didSet {
                guard zoomLevel != oldValue else { return }
                
                self.refreshAnnotationViewSize()
            }
        }
        
        func refreshAnnotationViewSize() {
            animateAnnotationViews { [weak self] in
                guard let self = self else { return }
                
                for annotation in self.parent.mapView.annotations {
                    if let annotation = annotation as? ProblemAnnotation {
                        let annotationView = self.parent.mapView.view(for: annotation) as? ProblemAnnotationView
                        
                        if(annotation.problem.belongsToCircuit) {
                            annotationView?.size = .full
                        }
                        else if(self.parent.dataStore.filters.favorite) {
                            annotationView?.size = .full
                        }
                        else if(self.parent.dataStore.problems.count < 30) {
                            annotationView?.size = .full
                        }
                        else if(annotation.problem.circuitColor == .offCircuit) {
                            switch self.zoomLevel {
                            case .zoomedIn:
                                annotationView?.size = .large
                            case .zoomedIntermediate:
                                annotationView?.size = .medium
                            case .zoomedOut:
                                annotationView?.size = .small
                            }
                        }
                        else {
                            switch self.zoomLevel {
                            case .zoomedIn:
                                annotationView?.size = .full
                            case .zoomedIntermediate:
                                annotationView?.size = .medium
                            case .zoomedOut:
                                annotationView?.size = .small
                            }
                        }
                    }
                }
            }
        }
        
        func animateAnnotationViews(_ animations: @escaping () -> Void) {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState], animations: animations, completion: nil)
        }
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        }
        
        // MARK: MKMapViewDelegate methods
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            
            //        if let multiPolygon = overlay as? MKMultiPolygon {
            //            let renderer = MKMultiPolygonRenderer(multiPolygon: multiPolygon)
            //            renderer.fillColor = UIColor(named: "OverlayFill")
            //            renderer.strokeColor = UIColor(named: "OverlayStroke")
            //            renderer.lineWidth = 2.0
            //
            //            return renderer
            //        }
            
            if let boulderOverlay = overlay as? BoulderOverlay {
                let renderer = MKMultiPolygonRenderer(multiPolygon: boulderOverlay)
                renderer.strokeColor = UIColor.init(white: 0.7, alpha: 1.0)
                renderer.lineWidth = 1
                renderer.fillColor = UIColor.init(white: 0.8, alpha: 1.0)
                renderer.lineJoin = .round
                return renderer
            }
            else if let circuitOverlay = overlay as? CircuitOverlay {
                
                let renderer = MKPolylineRenderer(polyline: circuitOverlay)
                renderer.strokeColor = circuitOverlay.strokeColor ?? UIColor.black
                renderer.lineWidth = 2
                renderer.lineDashPattern = [5,5]
                renderer.lineJoin = .bevel
                return renderer
            }
            else if let poiRouteOverlay = overlay as? PoiRouteOverlay {
                
                let renderer = MKPolylineRenderer(polyline: poiRouteOverlay)
                renderer.strokeColor = .gray
                renderer.lineWidth = 2
                renderer.lineDashPattern = [5,5]
                renderer.lineJoin = .bevel
                return renderer
            }
            else {
                return MKOverlayRenderer()
            }
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !annotation.isKind(of: MKUserLocation.self) else {
                return nil
            }
            
            if let annotation = annotation as? ProblemAnnotation {
                return ProblemAnnotationView(annotation: annotation, reuseIdentifier: ProblemAnnotationView.ReuseID)
            }
            else if let annotation = annotation as? PoiAnnotation {
                let annotationView = PoiAnnotationView(annotation: annotation, reuseIdentifier: PoiAnnotationView.ReuseID)
                annotationView.markerTintColor = annotation.tintColor
                annotationView.glyphText = String(annotation.title?.prefix(1) ?? "")
                
                return annotationView
            }
            
            return nil
        }
        
        func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
            if views.last?.annotation is MKUserLocation {
                addHeadingView(toAnnotationView: views.last!)
            }
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation {
                if let annotation = annotation as? PoiAnnotation {
                    parent.selectedPoi = annotation.poi
                    parent.presentPoiActionSheet = true
                    
                    mapView.deselectAnnotation(mapView.selectedAnnotations.first, animated: true)
                }
                
                if let annotation = annotation as? ProblemAnnotation {
                    parent.selectedProblem = annotation.problem
                    parent.presentProblemDetails = true
                    
                    mapView.deselectAnnotation(mapView.selectedAnnotations.first, animated: true)
                }
            }
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            if(mapView.camera.altitude < 150) {
                zoomLevel = .zoomedIn
            }
            else if(mapView.camera.altitude < 500) {
                zoomLevel = .zoomedIntermediate
            }
            else {
                zoomLevel = .zoomedOut
            }
            
            refreshAnnotationViewSize()
            
            self.updateHeadingRotation()
        }
        
        // MARK: CLLocationManagerDelegate methods
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            var firstTime = false
            
            if self.lastLocation == nil {
                firstTime = true
            }
            
            self.lastLocation = locations.last
            self.lastLocationAccuracy = lastLocation?.horizontalAccuracy
            
//            print("gps accuracy : \(lastLocationAccuracy!) m")
            
            if firstTime {
                locate()
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            locate()
        }
        
        func locate() {
            startLocationManager()
            
            if let lastLocation = lastLocation {
                
                // FIXME: filter by parking only
                if let parking = parent.dataStore.pois.first {
                    let distance = lastLocation.distance(from: CLLocation(latitude: parking.coordinate.latitude, longitude: parking.coordinate.longitude))
                    
                    if distance > 1_000 {
                        parent.mapView.setVisibleMapRect(
                            rectThatFits(parent.mapView.annotations, edgePadding: UIEdgeInsets(top: 80, left: 80, bottom: 160, right: 80)),
                            animated: true
                        )
                    }
                    else {
                        parent.mapView.setCamera(MKMapCamera(lookingAtCenter: CLLocationCoordinate2D(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude), fromDistance: 300, pitch: 0, heading: parent.mapView.camera.heading), animated: true)
                    }
                }
                else {
                    // TODO: handle case when there's no parking
                }
            }
            else {
//                print("no location yet")
            }
        }
        
        // inspired by https://gist.github.com/andrewgleave/915374
        func rectThatFits(_ annotations: [MKAnnotation], edgePadding: UIEdgeInsets = UIEdgeInsets(top: 40, left: 40, bottom: 120, right: 40)) -> MKMapRect {
            var rect = MKMapRect.null
            
            for annotation in annotations {
                let annotationPoint = MKMapPoint.init(annotation.coordinate)
                let pointRect = MKMapRect.init(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0)
                
                if rect.isNull {
                    rect = pointRect
                }
                else {
                    rect = rect.union(pointRect)
                }
            }
            
            return parent.mapView.mapRectThatFits(rect, edgePadding: edgePadding)
        }
        
        func startLocationManager() {
            locationManager.delegate = self
//            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            locationManager.headingFilter = ...
            
            NotificationCenter.default.addObserver(self, selector: #selector(deviceDidRotate), name: UIDevice.orientationDidChangeNotification, object: nil)
            
            locationManager.requestWhenInUseAuthorization()
            
            locationManager.startUpdatingHeading()
            locationManager.startUpdatingLocation()
        }
        
        @objc func deviceDidRotate() {
            // we do this to avoid default behavior (which is apparently to stay in portrait)
            // more info at https://developer.apple.com/documentation/corelocation/cllocationmanager/1620556-headingorientation
            
            switch UIDevice.current.orientation {
            case .landscapeLeft:
                locationManager.headingOrientation = .landscapeLeft
            case .landscapeRight:
                locationManager.headingOrientation = .landscapeRight
            case .portraitUpsideDown:
                locationManager.headingOrientation = .portraitUpsideDown
            case .unknown:
                locationManager.headingOrientation = .unknown
            case .portrait:
                locationManager.headingOrientation = .portrait
            case .faceUp:
                locationManager.headingOrientation = .faceUp
            case .faceDown:
                locationManager.headingOrientation = .faceDown
            @unknown default:
                locationManager.headingOrientation = .portrait
            }
        }
        
        // inspired by https://stackoverflow.com/questions/39762732/ios-10-heading-arrow-for-mkuserlocation-dot
        func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
            lastHeadingAccuracy = newHeading.headingAccuracy
            print("heading accuracy: \(newHeading.headingAccuracy)")

            if newHeading.headingAccuracy < 0 { return }

            let heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
            userHeading = heading
            print(userHeading)
            
            updateHeadingRotation()
        }
        
        func updateHeadingRotation() {
            if let heading = userHeading,
                let headingImageView = headingImageView {

                headingImageView.isHidden = false
                
//                let rotation = CGFloat((heading-parent.mapView.camera.heading)/180 * Double.pi)
//                headingImageView.transform = CGAffineTransform(rotationAngle: rotation)
                
                //print("current location x=\(headingImageView.superview!.center.x) y =\(headingImageView.superview!.center.y)")
                let userLocationInView = CGPoint(x: headingImageView.superview!.center.x, y:headingImageView.superview!.center.y)
                let userLocationInViewBound = CGPoint(x: headingImageView.superview!.center.x + 16, y:headingImageView.superview!.center.y)
                
                
                let userLocationCoordinate = parent.mapView.convert(userLocationInView, toCoordinateFrom: parent.mapView)
                let userLocationBoundCoordinate = parent.mapView.convert(userLocationInViewBound, toCoordinateFrom: parent.mapView)
                
                let location1 = CLLocation(latitude: userLocationCoordinate.latitude, longitude: userLocationCoordinate.longitude)
                let location2 = CLLocation(latitude: userLocationBoundCoordinate.latitude, longitude: userLocationBoundCoordinate.longitude)
                
                let distance = location1.distance(from: location2)
                
                //print("distance = \(distance)")
                
                UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState]) {
                    let rotation = CGFloat((heading-self.parent.mapView.camera.heading)/180 * Double.pi)
                    let rotateTransform = CGAffineTransform(rotationAngle: rotation)
                    
                    var scaleTransform = CGAffineTransform.identity
//                    headingImageView.transform = scaleTransform
                    
                    self.arrow.path = self.arrowPath(size: headingImageView.bounds.size, angleInDegrees: (self.lastHeadingAccuracy != nil) ? self.lastHeadingAccuracy!*2 : 180.0)
                    
                    if let lastLocationAccuracy = self.lastLocationAccuracy {
                        var scaleFactor = CGFloat(lastLocationAccuracy/distance)
                        if scaleFactor < 1.5 { scaleFactor = 1.5 }
                        if scaleFactor > 10 { scaleFactor = 10 }
                        scaleTransform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
                    }
                    
                    
                    headingImageView.transform = rotateTransform.concatenating(scaleTransform)
                }

            }
        }
        
        var headingImageView: UIImageView?
        var arrow: CAShapeLayer!
        var userHeading: CLLocationDirection?
        
        func addHeadingView(toAnnotationView annotationView: MKAnnotationView) {
            if headingImageView == nil {
                let image = UIImage(named: "heading")
                headingImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
                headingImageView!.frame = CGRect(x: (annotationView.frame.size.width - image!.size.width)/2, y: (annotationView.frame.size.height - image!.size.height)/2, width: image!.size.width, height: image!.size.height)
                
//                headingImageView?.backgroundColor = .red
                
                // This arrow overlays the dot and is rotated with the user’s heading.
                if arrow == nil {
                    arrow = CAShapeLayer()
                    arrow.frame = CGRect(x: 0, y: 0, width: headingImageView!.frame.size.width, height: headingImageView!.frame.size.height)
                    arrow.path = arrowPath(size: headingImageView!.bounds.size, angleInDegrees: (lastHeadingAccuracy != nil) ? lastHeadingAccuracy!*2 : 90.0)
                    
//                    arrow.position = CGPoint(x: headingImageView!.frame.midX, y: headingImageView!.frame.midY)
                    arrow.fillColor = UIColor.white.cgColor
                    
                    
                    let gradientLayer = CAGradientLayer()
                    gradientLayer.type = .radial
                    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
                    gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
                    
                    // make sure to use .cgColor
                    gradientLayer.colors = [
                        UIColor(Color.green).withAlphaComponent(0.8).cgColor,
                        UIColor(Color.green).withAlphaComponent(0.0).cgColor
                    ]
                    gradientLayer.frame = headingImageView!.bounds
                    gradientLayer.mask = arrow
                    
                    headingImageView!.layer.addSublayer(gradientLayer)
                   
//                    headingImageView!.layer.addSublayer(arrow)
                }

                
                annotationView.insertSubview(headingImageView!, at: 0)
                headingImageView!.isHidden = true
             }
        }
        
        // Calculate the vector path for an arrow, for use in a shape layer.
        private func arrowPath(size: CGSize, angleInDegrees: Double) -> CGPath {
//            let angleInDegrees: Double = 90
            let halfAngleInRadian = angleInDegrees/2 * Double.pi / 180
            
            let topLeft = CGPoint(
                x: (1.0-sin(halfAngleInRadian))/2*Double(size.width),
                y: (1.0-cos(halfAngleInRadian))/2*Double(size.height)
            )
            
            let center = CGPoint(
                x: size.width*0.5,
                y: size.height*0.5
            )
           
            let topRight = CGPoint(
                x: Double(size.width) - (1.0-sin(halfAngleInRadian))/2*Double(size.width),
                y: (1.0-cos(halfAngleInRadian))/2*Double(size.height)
            )
            
            let bezierPath = UIBezierPath()
            bezierPath.move(to: topLeft)
            bezierPath.addLine(to: center)
            bezierPath.addLine(to: topRight)
            bezierPath.close()
            
            return bezierPath.cgPath
        }

    }
}
