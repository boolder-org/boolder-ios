//
//  MapboxView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/10/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import MapboxMaps

struct MapboxView: UIViewControllerRepresentable {
     
    func makeUIViewController(context: Context) -> MapboxViewController {
           return MapboxViewController()
       }
      
    func updateUIViewController(_ uiViewController: MapboxViewController, context: Context) {
    }
}
