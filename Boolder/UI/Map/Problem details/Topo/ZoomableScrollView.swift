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
    @Binding var zoomScale: CGFloat
    @ViewBuilder var content: () -> Content

    func makeCoordinator() -> Coordinator {
        Coordinator(zoomScale: $zoomScale)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 1.0
        scrollView.bouncesZoom = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.zoomScale = zoomScale
        scrollView.contentInsetAdjustmentBehavior = .never

        // Add double tap gesture recognizer
        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delegate = context.coordinator
        scrollView.addGestureRecognizer(doubleTapGesture)

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
        // Only update content when not actively zooming to avoid performance issues
        if !context.coordinator.isZooming {
            context.coordinator.hostingController?.rootView = content()
        }
        context.coordinator.recenterContent(in: uiView)
        
        // Update zoom scale if it changed externally (not from user gesture)
        if !context.coordinator.isZooming && abs(uiView.zoomScale - zoomScale) > 0.01 {
            uiView.setZoomScale(zoomScale, animated: false)
        }
    }

    class Coordinator: NSObject, UIScrollViewDelegate, UIGestureRecognizerDelegate {
        var hostingController: UIHostingController<Content>?
        var zoomScaleBinding: Binding<CGFloat>
        var isZooming = false
        private var lastReportedScale: CGFloat = 1.0

        init(zoomScale: Binding<CGFloat>) {
            self.zoomScaleBinding = zoomScale
            self.lastReportedScale = zoomScale.wrappedValue
            super.init()
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }

        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            guard let scrollView = gesture.view as? UIScrollView else { return }
            scrollView.setZoomScale(1.0, animated: true)
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            hostingController?.view
        }
        
        func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
            isZooming = true
        }
        
        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            isZooming = false
            // Update SwiftUI state after zoom ends
            updateZoomScale(scale)
            // Trigger content update after zooming ends
            hostingController?.view.setNeedsLayout()
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            recenterContent(in: scrollView)
            // Only update binding periodically during zoom to reduce overhead
            let newScale = scrollView.zoomScale
            if abs(newScale - lastReportedScale) > 0.1 {
                updateZoomScale(newScale)
            }
        }
        
        private func updateZoomScale(_ scale: CGFloat) {
            lastReportedScale = scale
            DispatchQueue.main.async { [weak self] in
                self?.zoomScaleBinding.wrappedValue = scale
            }
        }

        func recenterContent(in scrollView: UIScrollView) {
            guard let view = hostingController?.view else { return }
            let offsetX = max((scrollView.bounds.width - view.frame.width) * 0.5, 0)
            let offsetY = max((scrollView.bounds.height - view.frame.height) * 0.5, 0)
            scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
        }
    }
}
