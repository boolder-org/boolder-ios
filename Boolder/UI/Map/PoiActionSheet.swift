//
//  PoiActionSheet.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 08/01/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//


import SwiftUI
import CoreLocation

struct PoiActionSheet: ViewModifier {
    @Binding var selectedPoi: Poi?
    
    @Environment(\.openURL) var openURL
    
    func body(content: Content) -> some View {
        content
            .confirmationDialog(
                selectedPoi?.name ?? "",
                isPresented: isPresentedBinding,
                titleVisibility: .visible,
                presenting: selectedPoi
            ) { poi in
                Button("Apple Maps") {
                    openAppleMaps(coordinates: poi.coordinate, name: poi.name)
                }
                
                if let googleUrl = URL(string: poi.googleUrl ?? "") {
                    Button("Google Maps") {
                        openURL(googleUrl)
                    }
                }
                
                if canOpenWaze() {
                    Button("Waze") {
                        openWaze(coordinates: poi.coordinate)
                    }
                }
                
                Button("poi.cancel", role: .cancel) { }
            }
    }
    
    private var isPresentedBinding: Binding<Bool> {
        Binding(
            get: { selectedPoi != nil },
            set: { if !$0 { selectedPoi = nil } }
        )
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

extension View {
    func poiActionSheet(selectedPoi: Binding<Poi?>) -> some View {
        modifier(PoiActionSheet(selectedPoi: selectedPoi))
    }
}
