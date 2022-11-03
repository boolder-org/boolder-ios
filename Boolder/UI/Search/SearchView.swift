//
//  SearchView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 03/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import UIKit
import SwiftUI
import CoreLocation

struct SearchView: UIViewControllerRepresentable {

    func makeUIViewController(context: UIViewControllerRepresentableContext<SearchView>) -> SearchViewController {
        
        let vc = SearchViewController()
//        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: SearchViewController, context: UIViewControllerRepresentableContext<SearchView>) {
        
    }
    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    final class Coordinator {
//
//        var parent: SearchView
//
//        init(_ parent: SearchView) {
//            self.parent = parent
//        }
//    }
}
