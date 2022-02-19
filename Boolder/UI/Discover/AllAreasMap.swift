//
//  AllAreasMap.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 18/02/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import MapKit

struct AllAreasMap: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    @State private var annotations: [AreaLocation] = []
//    [
//        AreaLocation(name: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275)),
//        AreaLocation(name: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508)),
//        AreaLocation(name: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5)),
//        AreaLocation(name: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667))
//        ]

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: annotations) { location in
            MapMarker(coordinate: location.coordinate) 
                
        }
        .onAppear {
            annotations = dataStore.areas.map { area in
                AreaLocation(name: area.name, coordinate: CLLocationCoordinate2D(latitude: area.latitude, longitude: area.longitude))
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .edgesIgnoringSafeArea([.bottom, .horizontal])
        .navigationTitle("Carte")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AreaLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct AllAreasMap_Previews: PreviewProvider {
    static var previews: some View {
        AllAreasMap()
    }
}
