//
//  MapView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import MapKit
import SwiftUI

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
    @Binding var zoomToRegion: Bool
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        mapView.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 10, maxCenterCoordinateDistance: 20_000_000), animated: true)
        
        let initialLocation = CLLocation(latitude: 48.461788, longitude: 2.663394)
        let regionRadius: CLLocationDistance = 1_000
        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: false)
        
        mapView.showsCompass = false
        mapView.showsScale = true
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        
        mapView.register(ProblemAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        mapView.addOverlays(dataStore.overlays)
        mapView.addAnnotations(dataStore.annotations)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        print("update map ui")
        
        if zoomToRegion {
            let initialLocation = CLLocation(latitude: 48.461788, longitude: 2.663394)
            let regionRadius: CLLocationDistance = 250
            let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            
            mapView.animatedZoom(zoomRegion: coordinateRegion, duration: 1)
        }
        
        // remove & add annotations back only if needed to avoid flickering
        
        let previousAnnotationsIds: [Int] = mapView.annotations.map{ annotation in
            if let problem = annotation as? ProblemAnnotation {
                return problem.id!
            } else {
                return 0
            }
        }
        
        let newAnnotationsIds: [Int] = dataStore.annotations.map{ $0.id! }
        
        let previousHash = previousAnnotationsIds.sorted().map{String($0)}.joined(separator: "-")
        let newHash = newAnnotationsIds.sorted().map{String($0)}.joined(separator: "-")
        
        if previousHash != newHash {
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)
            mapView.addAnnotations(dataStore.annotations)
            mapView.addOverlays(dataStore.overlays)
        }
        
        // refresh all annotation views
        
        for annotation in mapView.annotations {
            if let problem = annotation as? ProblemAnnotation {
                if let annotationView = mapView.view(for: problem) as? ProblemAnnotationView {
                    annotationView.refreshUI()
                }
            }
        }
    }
    
    private func reloadAnnotationsIfNeeded() {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: Coordinator
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        var mapView: MKMapView! = nil // FIXME: might crash
        
        private var annotationSize: ProblemAnnotationViewSize = .small {
            didSet {
                guard annotationSize != oldValue else { return }
                
                animateAnnotationViews { [weak self] in
                    guard let self = self else { return }
                    
                    for annotation in self.mapView.annotations {
                        guard let problem = annotation as? ProblemAnnotation else { return }
                        let annotationView = self.mapView.view(for: problem) as? ProblemAnnotationView
                        annotationView?.size = self.annotationSize
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
                renderer.strokeColor = UIColor.init(white: 0.55, alpha: 1.0)
                renderer.lineWidth = 1
                renderer.fillColor = UIColor.init(white: 0.65, alpha: 1.0)
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
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let problem = view.annotation as? ProblemAnnotation else { return }
            
            parent.selectedProblem = problem
            parent.presentProblemDetails = true
            
            mapView.deselectAnnotation(mapView.selectedAnnotations.first, animated: true)
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            self.mapView = mapView // FIXME: quick hack to pass mapview to annotationSize's property wrapper
            
            if(mapView.camera.altitude < 150) {
                annotationSize = .full
            }
            else if(mapView.camera.altitude < 500) {
                annotationSize = .medium
            }
            else {
                annotationSize = .small
            }
        }
    }
}
