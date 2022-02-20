//
//  AllAreasMapView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 18/02/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import MapKit
import SwiftUI

struct AllAreasMapView: UIViewRepresentable {
    @EnvironmentObject var dataStore: DataStore
    
    @Binding var selectedArea: Area?
    @Binding var presentArea: Bool
    @Binding var loading: Bool
    
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
            let annotation = AreaAnnotation(id: area.id, title: area.name,
                                            subtitle: String.localizedStringWithFormat(NSLocalizedString("all_areas.map.problems", comment: ""), String(area.problemsCount))
            )
            annotation.coordinate = CLLocationCoordinate2D(latitude: area.latitude, longitude: area.longitude)
            return annotation
        }
        
        mapView.layoutMargins = UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)
        
        mapView.showAnnotations(annotations, animated: true)
        
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
                annotationView.canShowCallout = true
                
                let rightButton = UIButton(type: .detailDisclosure)
                rightButton.setImage( UIImage(systemName: "chevron.right.circle"), for: .normal)
                annotationView.rightCalloutAccessoryView = rightButton

                return annotationView
            }

            return nil
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if let annotation = view.annotation {
                if let areaAnnotation = annotation as? AreaAnnotation {
                    parent.loading = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let area = self.parent.dataStore.area(withId: areaAnnotation.id)!
                        self.parent.dataStore.areaId = area.id
                        self.parent.dataStore.filters = Filters()
                        
                        self.parent.selectedArea = area
                        self.parent.presentArea = true
                    }
                }
            }
        }
    }
}

class AreaAnnotation: NSObject, MKAnnotation {
    // This property must be key-value observable, which the `@objc dynamic` attributes provide.
    @objc dynamic var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    internal var title: String?
    internal var subtitle: String?
    let id: Int
    var tintColor = UIColor(red: 5/255, green: 150/255, blue: 105/255, alpha: 1.0)
    
    init(id: Int, title: String, subtitle: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
    }
}
