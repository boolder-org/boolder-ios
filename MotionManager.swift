import SwiftUI
import CoreMotion

/// 1. MotionManager that records a baseline attitude on first update
final class MotionManager: ObservableObject {
    private let motion = CMMotionManager()
    
    @Published private(set) var roll: Double = 0
    @Published private(set) var pitch: Double = 0
    
    // Baseline values (set once)
    private var baselineRoll: Double?
    private var baselinePitch: Double?
    
    init(updateInterval: TimeInterval = 1/60) {
        motion.deviceMotionUpdateInterval = updateInterval
        guard motion.isDeviceMotionAvailable else { return }
        motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let self = self, let attitude = data?.attitude else { return }
            
            // On the very first update, record the baseline
            if self.baselineRoll == nil && self.baselinePitch == nil {
                self.baselineRoll  = attitude.roll
                self.baselinePitch = attitude.pitch
            }
            
            // Subtract baseline so 0 = “level at launch”
            let rawRoll  = attitude.roll
            let rawPitch = attitude.pitch
            
            self.roll  = rawRoll - (self.baselineRoll  ?? 0)
            self.pitch = rawPitch - (self.baselinePitch ?? 0)
        }
    }
    
    deinit {
        motion.stopDeviceMotionUpdates()
    }
    
    /// Call this if you want to “re‑zero” the baseline later
    func resetBaseline() {
        baselineRoll = nil
        baselinePitch = nil
    }
}
