//
//  PoiActionSheet.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 08/01/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//


import SwiftUI
import CoreLocation

struct PoiActionSheet: View {
    let name: String
    let googleUrl: URL?
    let coordinates: CLLocationCoordinate2D
    
    @Environment(\.openURL) var openURL
    @Binding var presentPoiActionSheet: Bool
    
    var body: some View {
        EmptyView()
            .actionSheet(isPresented: $presentPoiActionSheet) {
                ActionSheet(
                    title: Text(name),
                    buttons: buttons
                )
        }
    }
    
    private var buttons : [Alert.Button] {
        var buttons = [Alert.Button]()
        
        buttons.append(
            .default(Text("Apple Maps")) {
                openAppleMaps(coordinates: coordinates, name: name)
            }
        )
        
        if let googleUrl = googleUrl {
            buttons.append(
                .default(Text("Google Maps")) {
                    openURL(googleUrl)
                }
            )
        }
        
        if canOpenWaze() {
            buttons.append(
                .default(Text("Waze")) {
                    openWaze(coordinates: coordinates)
                }
            )
        }
        
        buttons.append(
            .cancel(Text("poi.cancel"))
        )
        
        return buttons
    }
    
    private func openAppleMaps(coordinates: CLLocationCoordinate2D, name: String) {
        let urlString = "http://maps.apple.com/?q=\(name)&ll=\(coordinates.latitude),\(coordinates.longitude)"
        if let url = URL(string: urlString) {
            openURL(url)
        }
    }
    
    private func openWaze(coordinates: CLLocationCoordinate2D) {
        let urlString = "waze://?ll=\(coordinates.latitude),\(coordinates.longitude)&navigate=yes"
        if let url = URL(string: urlString) {
            openURL(url)
        }
    }
    
    private func canOpenWaze() -> Bool {
        guard let url = URL(string: "waze://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}
