//
//  ZoomableScrollView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 26/04/2025.
//  Copyright © 2025 Nicolas Mondollot. All rights reserved.
//


import UIKit
import SwiftUI

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    let content: Content
    @Binding var zoomScale: CGFloat

    init(zoomScale: Binding<CGFloat>, @ViewBuilder content: () -> Content) {
        self._zoomScale = zoomScale
        self.content = content()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.bouncesZoom = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = false

        let hosted = context.coordinator.hostingController.view!
        hosted.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(hosted)
        NSLayoutConstraint.activate([
            hosted.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hosted.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hosted.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hosted.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            hosted.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            hosted.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
        
        // Set initial content size to match the scroll view's size
        scrollView.contentSize = scrollView.bounds.size
        
        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.hostingController.rootView = content
    }

    func makeCoordinator() -> Coordinator {
        let hostingController = UIHostingController(rootView: content)
        return Coordinator(hostingController: hostingController, zoomScale: $zoomScale)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        let hostingController: UIHostingController<Content>
        let zoomScale: Binding<CGFloat>

        init(hostingController: UIHostingController<Content>, zoomScale: Binding<CGFloat>) {
            self.hostingController = hostingController
            self.zoomScale = zoomScale
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            zoomScale.wrappedValue = scrollView.zoomScale
        }
        
        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            zoomScale.wrappedValue = scrollView.minimumZoomScale
        }
    }
}
