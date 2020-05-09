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

extension MKMapView {
    func animatedZoom(zoomRegion:MKCoordinateRegion, duration:TimeInterval) {
        MKMapView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.5, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.setRegion(zoomRegion, animated: true)
            }, completion: nil)
    }
}

struct MapView: UIViewRepresentable {
    @EnvironmentObject var dataStore: DataStore
    @Binding var selectedProblem: ProblemAnnotation
    @Binding var presentProblemDetails: Bool
    @Binding var presentParkingActionSheet: Bool
    
    var mapView = MKMapView()
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        
        mapView.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 10, maxCenterCoordinateDistance: 20_000_000), animated: true)
        
        let initialLocation = CLLocation(latitude: 48.461788, longitude: 2.663394)
        let regionRadius: CLLocationDistance = 1_000
        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: false)
        
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.showsScale = true
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        
        mapView.register(ProblemAnnotationView.self, forAnnotationViewWithReuseIdentifier: ProblemAnnotationView.ReuseID)
        mapView.register(PoiAnnotationView.self, forAnnotationViewWithReuseIdentifier: PoiAnnotationView.ReuseID)
        
        mapView.addOverlays(dataStore.overlays)
        self.mapView.addAnnotations(self.dataStore.annotations)
//        self.mapView.addAnnotation(self.dataStore.parkingAnnotation())
        self.zoomToRegion(mapView: self.mapView)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            context.coordinator.showUserLocation()
//        }
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {

        // remove & add annotations back only if needed to avoid flickering
        
        let previousAnnotationsIds: [Int] = mapView.annotations.compactMap{ annotation in
            if let problem = annotation as? ProblemAnnotation {
                return problem.id!
            } else {
                return nil
            }
        }
        
        let newAnnotationsIds: [Int] = dataStore.annotations.map{ $0.id! }
        
        let previousHash = previousAnnotationsIds.sorted().map{String($0)}.joined(separator: "-")
        let newHash = newAnnotationsIds.sorted().map{String($0)}.joined(separator: "-")
        
        if previousHash != newHash && context.coordinator.didStartAnimation {
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)
            mapView.addAnnotations(dataStore.annotations)
            mapView.addOverlays(dataStore.overlays)
//            mapView.addAnnotation(self.dataStore.parkingAnnotation())
        }
        
        // refresh all annotation views
        // FIXME: doesn't seem to work syncronously
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            context.coordinator.refreshAnnotationViewSize()
        }
        
        for annotation in mapView.annotations {
            if let problem = annotation as? ProblemAnnotation {
                if let annotationView = mapView.view(for: problem) as? ProblemAnnotationView {
                    annotationView.refreshUI()
                }
            }
        }
        
        // zoom to new region
        
        let changedCircuit = context.coordinator.lastCircuit != dataStore.filters.circuit && dataStore.filters.circuit != nil
        context.coordinator.lastCircuit = dataStore.filters.circuit
        
        if changedCircuit {
            zoomToRegion(mapView: mapView)
        }
    }
    
    func zoomToRegion(mapView: MKMapView) {
//        let initialLocation = CLLocation(latitude: 48.461788 + Double.random(in: 0..<0.00001), longitude: 2.663394) // randomize to trigger map annotations collisions
//        let regionRadius: CLLocationDistance = 250
//        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
//
//        mapView.animatedZoom(zoomRegion: coordinateRegion, duration: 1)
        mapView.showAnnotations(mapView.annotations, animated: true)
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
        var lastCircuit: Circuit.CircuitType? = nil
        var didStartZoom = false
        var didStartAnimation = false
        var locationManager = CLLocationManager()
        
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
                    if let problem = annotation as? ProblemAnnotation {
                        let annotationView = self.parent.mapView.view(for: problem) as? ProblemAnnotationView
                        
                        if(problem.belongsToCircuit) {
                            annotationView?.size = .full
                        }
                        else if(self.parent.dataStore.filters.favorite) {
                            annotationView?.size = .full
                        }
                        else if(self.parent.dataStore.annotations.count < 30) {
                            annotationView?.size = .full
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
        
//        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//            print(status.rawValue)
//        }
        
        func showUserLocation() {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        }
        
        // MARK: MKMapViewDelegate delegate methods
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            
            //        if let multiPolygon = overlay as? MKMultiPolygon {
            //            let renderer = MKMultiPolygonRenderer(multiPolygon: multiPolygon)
            //            renderer.fillColor = UIColor(named: "OverlayFill")
            //            renderer.strokeColor = UIColor(named: "OverlayStroke")
            //            renderer.lineWidth = 2.0
            //
            //            return renderer
            //        }
            
            if let multiPolygon = overlay as? MKMultiPolygon {
                let renderer = MKMultiPolygonRenderer(multiPolygon: multiPolygon)
                renderer.strokeColor = UIColor.init(white: 0.7, alpha: 1.0)
                renderer.lineWidth = 1
                renderer.fillColor = UIColor.init(white: 0.8, alpha: 1.0)
                renderer.lineJoin = .round
                return renderer
            }
            else if let circuitOverlay = overlay as? CircuitOverlay {
                let renderer = MKPolylineRenderer(polyline: circuitOverlay)
                renderer.strokeColor = Circuit(circuitOverlay.circuitType ?? Circuit.CircuitType.orange).color
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
                annotationView.canShowCallout = true
                annotationView.markerTintColor = annotation.tintColor
                annotationView.glyphText = "P"
                annotationView.rightCalloutAccessoryView = UIButton(type: .infoLight)
                
                return annotationView
            }
            
            return nil
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            
            if let annotation = view.annotation, annotation.isKind(of: PoiAnnotation.self) {
                parent.presentParkingActionSheet = true
            }
        }
        
        func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
            guard !didStartAnimation else { return }

            for view in views {
                if view.annotation is MKUserLocation {
                    continue;
                }

                view.alpha = 0.0

                UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations:{() in
                    view.alpha = 1.0
                })
            }
            
            didStartAnimation = true
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let problem = view.annotation as? ProblemAnnotation else { return }
            
            parent.selectedProblem = problem
            parent.presentProblemDetails = true
            
            mapView.deselectAnnotation(mapView.selectedAnnotations.first, animated: true)
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
        }
    }
}
