//
//  PinchToZoom.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 12/01/2021.
//  Copyright © 2021 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import UIKit

// inspired by https://github.com/Jake-Short/swiftui-image-viewer
struct PinchToZoom: UIViewRepresentable {

    @Binding var scale: CGFloat
    @Binding var anchor: UnitPoint
    @Binding var offset: CGSize
    @Binding var isPinching: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> PinchToZoomView {
        let pinchToZoomView = PinchToZoomView()
        pinchToZoomView.delegate = context.coordinator
        return pinchToZoomView
    }

    func updateUIView(_ pageControl: PinchToZoomView, context: Context) { }

    class Coordinator: NSObject, PinchToZoomViewDelgate {
        var parent: PinchToZoom

        init(_ pinchToZoom: PinchToZoom) {
            self.parent = pinchToZoom
        }
        
        let animation = Animation.spring(response: 0.55, dampingFraction: 0.725)
        
        func animate(stuff: () -> ()) {
            if(!parent.isPinching) {
                withAnimation(animation) {
                    stuff()
                }
            }
            else {
                stuff()
            }
        }

        func pinchToZoomView(_ pinchToZoomView: PinchToZoomView, didChangePinching isPinching: Bool) {
            parent.isPinching = isPinching
        }

        func pinchToZoomView(_ pinchToZoomView: PinchToZoomView, didChangeScale scale: CGFloat) {
            animate {
                parent.scale = scale
            }
        }

        func pinchToZoomView(_ pinchToZoomView: PinchToZoomView, didChangeAnchor anchor: UnitPoint) {
            animate {
                parent.anchor = anchor
            }
        }
        
        func pinchToZoomView(_ pinchToZoomView: PinchToZoomView, didChangeOffset offset: CGSize) {
            animate {
                parent.offset = offset
            }
        }
    }
}

class PinchToZoomView: UIView {

    weak var delegate: PinchToZoomViewDelgate?

    private(set) var scale: CGFloat = 0 {
        didSet {
            delegate?.pinchToZoomView(self, didChangeScale: scale)
        }
    }

    private(set) var anchor: UnitPoint = .center {
        didSet {
            delegate?.pinchToZoomView(self, didChangeAnchor: anchor)
        }
    }

    private(set) var offset: CGSize = .zero {
        didSet {
            delegate?.pinchToZoomView(self, didChangeOffset: offset)
        }
    }

    private(set) var isPinching: Bool = false {
        didSet {
            delegate?.pinchToZoomView(self, didChangePinching: isPinching)
        }
    }

    private var startLocation: CGPoint = .zero
    private var location: CGPoint = .zero
    private var numberOfTouches: Int = 0

    init() {
        super.init(frame: .zero)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
        pinchGesture.cancelsTouchesInView = false
        addGestureRecognizer(pinchGesture)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc private func pinch(gesture: UIPinchGestureRecognizer) {

        switch gesture.state {
        case .began:
            isPinching = true
            startLocation = gesture.location(in: self)
            anchor = UnitPoint(x: startLocation.x / bounds.width, y: startLocation.y / bounds.height)
            numberOfTouches = gesture.numberOfTouches

        case .changed:
            if gesture.numberOfTouches != numberOfTouches {
                // If the number of fingers being used changes, the start location needs to be adjusted to avoid jumping.
                let newLocation = gesture.location(in: self)
                let jumpDifference = CGSize(width: newLocation.x - location.x, height: newLocation.y - location.y)
                startLocation = CGPoint(x: startLocation.x + jumpDifference.width, y: startLocation.y + jumpDifference.height)

                numberOfTouches = gesture.numberOfTouches
            }

            scale = gesture.scale

            location = gesture.location(in: self)
            offset = CGSize(width: location.x - startLocation.x, height: location.y - startLocation.y)

        case .ended, .cancelled, .failed:
            isPinching = false
            scale = 1.0
            anchor = .center
            offset = .zero
        default:
            break
        }
    }

}

protocol PinchToZoomViewDelgate: AnyObject {
    func pinchToZoomView(_ pinchToZoomView: PinchToZoomView, didChangePinching isPinching: Bool)
    func pinchToZoomView(_ pinchToZoomView: PinchToZoomView, didChangeScale scale: CGFloat)
    func pinchToZoomView(_ pinchToZoomView: PinchToZoomView, didChangeAnchor anchor: UnitPoint)
    func pinchToZoomView(_ pinchToZoomView: PinchToZoomView, didChangeOffset offset: CGSize)
}
