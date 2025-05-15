//
//  ZoomableScrollView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 26/04/2025.
//  Copyright © 2025 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

// MARK: – ZoomableScrollView
struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    @ViewBuilder var content: () -> Content

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 1.0
        scrollView.bouncesZoom = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        // Host SwiftUI content
        let hostedController = UIHostingController(rootView: content())
        hostedController.view.backgroundColor = .clear
        context.coordinator.hostingController = hostedController
        scrollView.addSubview(hostedController.view)

        // Pin hosted view to scroll view's content and frame guides
        hostedController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostedController.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            hostedController.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            hostedController.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            hostedController.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            hostedController.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            hostedController.view.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // Update content and recenter on layout/zoom changes
        context.coordinator.hostingController?.rootView = content()
        context.coordinator.recenterContent(in: uiView)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>?

        override init() {
            super.init()
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            hostingController?.view
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            recenterContent(in: scrollView)
        }

        /// Centers the hosted view within the scroll view if it's smaller than the scroll view bounds.
        func recenterContent(in scrollView: UIScrollView) {
            guard let view = hostingController?.view else { return }
            let offsetX = max((scrollView.bounds.width - view.frame.width) * 0.5, 0)
            let offsetY = max((scrollView.bounds.height - view.frame.height) * 0.5, 0)
            scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
        }
    }
}
