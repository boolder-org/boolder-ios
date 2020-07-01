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
    
    var mapView = MKMapView()
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        
        mapView.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 10, maxCenterCoordinateDistance: 20_000_000), animated: true)
        
        let initialLocation = CLLocation(latitude: 48.461788, longitude: 2.663394)
        let regionRadius: CLLocationDistance = 1_000
        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: false)
        
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = false
        
        mapView.register(ProblemAnnotationView.self, forAnnotationViewWithReuseIdentifier: ProblemAnnotationView.ReuseID)
        mapView.register(PoiAnnotationView.self, forAnnotationViewWithReuseIdentifier: PoiAnnotationView.ReuseID)
        
        mapView.addOverlays(dataStore.overlays)
        self.mapView.addAnnotations(self.dataStore.problems.map{$0.annotation})
        self.mapView.addAnnotations(self.dataStore.pois.compactMap{$0.annotation})
        self.zoomToRegion(mapView: self.mapView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            context.coordinator.showUserLocation()
        }
        
        return mapView
    }
    
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
        
        if previousHash != newHash && context.coordinator.didStartAnimation {
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)
            mapView.addAnnotations(self.dataStore.problems.map{$0.annotation})
            mapView.addAnnotations(self.dataStore.pois.compactMap{$0.annotation})
            mapView.addOverlays(dataStore.overlays)
        }
        
        // refresh all annotation views
        // FIXME: doesn't seem to work syncronously
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            context.coordinator.refreshAnnotationViewSize()
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
            zoomToRegion(mapView: mapView)
        }
    }
    
    func zoomToRegion(mapView: MKMapView) {
        MKMapView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.5, options: UIView.AnimationOptions.curveEaseIn, animations: {
            mapView.showAnnotations(self.dataStore.problems.map{$0.annotation}, animated: true)
        }, completion: nil)
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
                annotationView.canShowCallout = true
                annotationView.markerTintColor = annotation.tintColor
                annotationView.glyphText = String(annotation.title?.prefix(1) ?? "")
                annotationView.rightCalloutAccessoryView = UIButton(type: .infoLight)
                
                return annotationView
            }
            
            return nil
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            
            if let annotation = view.annotation {
                if let annotation = annotation as? PoiAnnotation {
                    parent.selectedPoi = annotation.poi
                    parent.presentPoiActionSheet = true
                }
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
            guard let annotation = view.annotation as? ProblemAnnotation else { return }
            
            parent.selectedProblem = annotation.problem
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
            
            refreshAnnotationViewSize()
        }
    }
}
