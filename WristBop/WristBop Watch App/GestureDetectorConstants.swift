import Foundation

enum GestureDetectorConstants {
    static let motionUpdateInterval: TimeInterval = 1.0 / 50.0

    static let sampleWindow: TimeInterval = 0.6

    static let shakeAccelerationThreshold: Double = 2.2
    static let shakePeakSeparation: TimeInterval = 0.12
    static let shakePeaksRequired: Int = 2

    static let flickUpAccelerationThreshold: Double = 1.6

    static let twistRotationThreshold: Double = 5.0

    static let crownDeltaThreshold: Double = 0.35
}
