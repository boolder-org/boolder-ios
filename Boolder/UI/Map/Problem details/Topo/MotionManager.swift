//
//  MotionManager.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/08/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import CoreMotion

class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0
    
    init() {
        startMotionUpdates()
    }
    
    func startMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { (data, error) in
                if let validData = data {
                    self.pitch = validData.attitude.pitch
                    self.roll = validData.attitude.roll
                }
            }
        }
    }
}
