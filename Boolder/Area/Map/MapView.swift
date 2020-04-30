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

struct MapView: UIViewRepresentable {
    @EnvironmentObject var dataStore: DataStore
    @Binding var selectedProblem: ProblemAnnotation
    @Binding var presentProblemDetails: Bool
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        let initialLocation = CLLocation(latitude: 48.461788, longitude: 2.663394)
        
        let regionRadius: CLLocationDistance = 250
        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        
        mapView.showsCompass = false
        mapView.showsScale = true
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        
        mapView.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 10, maxCenterCoordinateDistance: 20_000_000), animated: true)
        
        mapView.register(ProblemAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        mapView.addOverlays(dataStore.overlays)
        mapView.addAnnotations(dataStore.annotations)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        print("update map ui")
        
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
        
        private var annotationSize: ProblemAnnotationViewSize = .dot {
            didSet {
                guard annotationSize != oldValue else { return }
                
                animateAnnotationViews { [weak self] in
                    guard let self = self else { return }
                    
                    self.mapView.annotations.forEach {
                        (self.mapView.view(for: $0) as? ProblemAnnotationView)?.size = self.annotationSize
                    }
                }
            }
        }
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func animateAnnotationViews(_ animations: @escaping () -> Void) {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState], animations: animations, completion: nil)
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
                renderer.strokeColor = UIColor.init(white: 0.6, alpha: 1.0)
                renderer.lineWidth = 1
                renderer.fillColor = UIColor.init(white: 0.7, alpha: 1.0)
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
            self.mapView = mapView
            
            if(mapView.camera.altitude < 150) {
                annotationSize = .full
            }
            else {
                annotationSize = .dot
            }
        }
    }
}
