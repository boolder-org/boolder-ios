//
//  PoiActionSheet.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 04/05/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import MapKit
import SwiftUI

struct PoiActionSheet: View {
    @Binding var presentParkingActionSheet: Bool
    let location = CLLocationCoordinate2D(latitude: 48.462965, longitude: 2.665628)
    
    func buttons() -> [Alert.Button] {
        var buttons = [Alert.Button]()
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            buttons.append(
                .default(Text("Google Maps")) {
                    UIApplication.shared.open(URL(string: "comgooglemaps://?daddr=\(self.location.latitude),\(self.location.longitude)")!)
                }
            )
        }
        
        if UIApplication.shared.canOpenURL(URL(string: "waze://")!) {
            buttons.append(
                .default(Text("Waze")) {
                    let urlStr: String = "waze://?ll=\(self.location.latitude),\(self.location.longitude)&navigate=yes"
                    UIApplication.shared.open(URL(string: urlStr)!)
                }
            )
        }
        
        buttons.append(
            .default(Text("Apple Maps")) {
                let destination = MKMapItem(placemark: MKPlacemark(coordinate: self.location))
                destination.name = "Parking Rocher Canon"

                MKMapItem.openMaps(with: [destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            }
        )
        
        buttons.append(
            .default(Text("Coordonnées GPS"))
        )
        
        buttons.append(
            .cancel(Text("Annuler"))
        )
        
        return buttons
    }
    
    var body: some View {
        EmptyView()
            .actionSheet(isPresented: $presentParkingActionSheet) {
                ActionSheet(
                    title: Text("Ouvrir dans :"),
                    buttons: buttons()
                )
            }
    }
}
