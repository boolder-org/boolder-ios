//
//  PoiActionSheet.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 04/05/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import MapKit
import SwiftUI

struct OldPoiActionSheet: View {
    let name: String
    let location: CLLocationCoordinate2D
    let googleUrl: URL?
    let navigationMode: Bool
    
    @Environment(\.openURL) var openURL
    @Binding var presentPoiActionSheet: Bool
    @State private var presentShareSheet = false
    
    var body: some View {
        EmptyView()
            .actionSheet(isPresented: $presentPoiActionSheet) {
                ActionSheet(
                    title: Text(name),
                    buttons: buttons()
                )
        }
        .background(
            EmptyView()
                .sheet(isPresented: $presentShareSheet) {
                    ShareSheet(activityItems: [
                        String.localizedStringWithFormat(NSLocalizedString("poi.gps_coordinates_for_poi", comment: ""), name, round(location.latitude), round(location.longitude))
                    ])
                }
        )
    }
    
    private func round(_ number: CLLocationDegrees) -> String {
        String(format: "%.6f", number)
    }
    
    private func buttons() -> [Alert.Button] {
        var buttons = [Alert.Button]()
        
        if let googleUrl = googleUrl {
            buttons.append(
                .default(Text(
                    String.localizedStringWithFormat(NSLocalizedString("poi.see_in", comment: ""), "Google Maps")
                )) {
                    openURL(googleUrl)
                }
            )
        }
        // Fallback to classic google url if we don't have a direct link
        else if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            buttons.append(
                .default(Text(
                    String.localizedStringWithFormat(NSLocalizedString("poi.see_in", comment: ""), "Google Maps")
                )) {
                    let param = navigationMode ? "daddr" : "q"
                    UIApplication.shared.open(URL(string: "comgooglemaps://?\(param)=\(round(location.latitude)),\(round(location.longitude))")!)
                }
            )
        }
        
        
        if UIApplication.shared.canOpenURL(URL(string: "waze://")!) && navigationMode {
            buttons.append(
                .default(Text(
                    String.localizedStringWithFormat(NSLocalizedString("poi.see_in", comment: ""), "Waze")
                )) {
                    let urlStr: String = "waze://?ll=\(round(location.latitude)),\(round(location.longitude))&navigate=yes"
                    UIApplication.shared.open(URL(string: urlStr)!)
                }
            )
        }
        
        buttons.append(
            .default(Text(
                String.localizedStringWithFormat(NSLocalizedString("poi.see_in", comment: ""), "Apple Maps")
            )) {
                let destination = MKMapItem(placemark: MKPlacemark(coordinate: location))
                destination.name = name

                if navigationMode {
                    MKMapItem.openMaps(with: [destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                }
                else {
                    MKMapItem.openMaps(with: [destination])
                }
            }
        )
        
        buttons.append(
            .default(Text("poi.share_gps_coordinates")) {
                presentShareSheet = true
            }
        )
        
        buttons.append(
            .cancel(Text("poi.cancel"))
        )
        
        return buttons
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
