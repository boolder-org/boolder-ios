//
//  AllAreasMap.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 18/02/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

//
//  MapView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import MapKit
import SwiftUI

struct AllAreasMapView: UIViewRepresentable {
    @EnvironmentObject var dataStore: DataStore
    
    @Binding var selectedArea: Area?
    @Binding var presentArea: Bool
    
    var mapView = MKMapView() // FIXME: put in makeUIView() ?
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        
        mapView.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 10, maxCenterCoordinateDistance: 20_000_000), animated: true)
        
        let initialLocation = CLLocation(latitude: 48.461788, longitude: 2.663394)
        let regionRadius: CLLocationDistance = 7_000
        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: false)
        
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.showsScale = true
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        
        let annotations: [AreaAnnotation] =  dataStore.areas.filter{$0.published}.map { area in
            let annotation = AreaAnnotation(id: area.id, title: area.name)
            annotation.coordinate = CLLocationCoordinate2D(latitude: area.latitude, longitude: area.longitude)
            return annotation
        }
        
        mapView.layoutMargins = UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)
        
//        mapView.addAnnotations(annotations)
        mapView.showAnnotations(annotations, animated: true)

//
//        let london = MKPointAnnotation()
//        london.title = "London"
//        london.coordinate = CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275)
//        mapView.addAnnotation(london)
        
//        mapView.register(ProblemAnnotationView.self, forAnnotationViewWithReuseIdentifier: ProblemAnnotationView.ReuseID)
//        mapView.register(PoiAnnotationView.self, forAnnotationViewWithReuseIdentifier: PoiAnnotationView.ReuseID)
        
        return mapView
    }
    
    
    func updateUIView(_ mapView: MKMapView, context: Context) {

        
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: Coordinator
    
    class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        
        var parent: AllAreasMapView
        
        init(_ parent: AllAreasMapView) {
            self.parent = parent
        }

        
        // MARK: MKMapViewDelegate methods
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !annotation.isKind(of: MKUserLocation.self) else {
                return nil
            }

            if let annotation = annotation as? AreaAnnotation {
                let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "areaAnnotation")
                annotationView.markerTintColor = annotation.tintColor
                annotationView.clusteringIdentifier = "cluster"

                return annotationView
            }

            return nil
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation {
                if let areaAnnotation = annotation as? AreaAnnotation {
                    let area = parent.dataStore.area(withId: areaAnnotation.id)!
                    parent.dataStore.areaId = area.id
                    parent.dataStore.filters = Filters()

                    parent.selectedArea = area
                    parent.presentArea = true
                    
                    mapView.deselectAnnotation(mapView.selectedAnnotations.first, animated: false)
                }
            }
        }
        
    }
}

class AreaAnnotation: NSObject, MKAnnotation {
    // This property must be key-value observable, which the `@objc dynamic` attributes provide.
    @objc dynamic var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    internal var title: String?
    let id: Int
    var tintColor = UIColor(red: 5/255, green: 150/255, blue: 105/255, alpha: 1.0)
    
    init(id: Int, title: String) {
        self.id = id
        self.title = title
    }
}
