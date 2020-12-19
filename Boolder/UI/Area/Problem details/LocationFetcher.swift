//
//  LocationFetcher.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 13/12/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import CoreLocation
import Combine

class LocationFetcher: NSObject, ObservableObject, CLLocationManagerDelegate {
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    let manager = CLLocationManager()
    
    @Published var location: CLLocation? {
        willSet { objectWillChange.send() }
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func start() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
}
