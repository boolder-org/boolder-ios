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
    @Binding var presentPoiActionSheet: Bool
    @Binding var selectedPoi: Poi?
    @State private var showShareSheet = false
    
    var location: CLLocationCoordinate2D {
        selectedPoi?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    
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
                destination.name = self.selectedPoi?.description ?? ""

                MKMapItem.openMaps(with: [destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            }
        )
        
        buttons.append(
            .default(Text("Coordonnées GPS")) {
                self.showShareSheet = true
            }
        )
        
        buttons.append(
            .cancel(Text("Annuler"))
        )
        
        return buttons
    }
    
    var body: some View {
        EmptyView()
            .actionSheet(isPresented: $presentPoiActionSheet) {
                ActionSheet(
                    title: Text("Ouvrir dans :"),
                    buttons: buttons()
                )
        }
        .background(
            EmptyView()
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(activityItems: ["Coordonnées GPS \(self.selectedPoi?.description ?? "") : \(self.location.latitude),\(self.location.longitude)"])
                }
        )
    }
}


struct ShareSheet: UIViewControllerRepresentable {
    typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
      
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    let callback: Callback? = nil
      
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        return controller
    }
      
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }
}
