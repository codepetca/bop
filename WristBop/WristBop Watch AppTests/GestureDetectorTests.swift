import CoreMotion
import Testing
import WatchKit
@testable import WristBop_Watch_App
import WristBopCore

@Suite("GestureDetector")
struct GestureDetectorTests {

    @Test("Flick up detection emits once")
    func testFlickUpDetection() async throws {
        let delegate = CapturingDelegate()
        let detector = GestureDetector(
            motionManager: FakeMotionManager(),
            crownSequencer: FakeCrownSequencer()
        )
        detector.delegate = delegate
        detector.setActiveCommand(.flickUp)

        let flickSample = MotionSample(
            userAcceleration: CMAcceleration(x: 0, y: GestureDetectorConstants.flickUpAccelerationThreshold + 0.2, z: 0),
            rotationRate: CMRotationRate(x: 0, y: 0, z: 0),
            timestamp: 0
        )

        detector.injectSample(flickSample)
        try await waitForDetections(delegate, expected: [.flickUp])
    }

    @Test("Shake requires multiple peaks")
    func testShakeDetection() async throws {
        let delegate = CapturingDelegate()
        let detector = GestureDetector(
            motionManager: FakeMotionManager(),
            crownSequencer: FakeCrownSequencer()
        )
        detector.delegate = delegate
        detector.setActiveCommand(.shake)

        let peak1 = MotionSample(
            userAcceleration: CMAcceleration(x: GestureDetectorConstants.shakeAccelerationThreshold + 0.5, y: 0, z: 0),
            rotationRate: CMRotationRate(x: 0, y: 0, z: 0),
            timestamp: 0
        )
        let peak2 = MotionSample(
            userAcceleration: CMAcceleration(x: 0, y: GestureDetectorConstants.shakeAccelerationThreshold + 0.5, z: 0),
            rotationRate: CMRotationRate(x: 0, y: 0, z: 0),
            timestamp: GestureDetectorConstants.shakePeakSeparation + 0.01
        )

        detector.injectSample(peak1)
        detector.injectSample(peak2)
        try await waitForDetections(delegate, expected: [.shake])
    }

    @Test("Crown spin triggers detection")
    func testCrownDetection() async throws {
        let delegate = CapturingDelegate()
        let fakeCrown = FakeCrownSequencer()
        let detector = GestureDetector(
            motionManager: FakeMotionManager(),
            crownSequencer: fakeCrown
        )
        detector.delegate = delegate
        detector.setActiveCommand(.spinCrown)

        detector.start()
        fakeCrown.simulateRotation(delta: GestureDetectorConstants.crownDeltaThreshold + 0.1)

        try await waitForDetections(delegate, expected: [.spinCrown])
    }

    // MARK: - Test helpers

    private func waitForDetections(_ delegate: CapturingDelegate, expected: [GestureType]) async throws {
        try await Task.sleep(nanoseconds: 50_000_000) // 50ms
        #expect(delegate.detected == expected)
    }
}

private final class CapturingDelegate: GestureDetectorDelegate {
    var detected: [GestureType] = []

    func gestureDetector(_ detector: GestureDetector, didDetect gesture: GestureType) {
        detected.append(gesture)
    }
}

private final class FakeMotionManager: MotionManagerProtocol {
    var isDeviceMotionAvailable: Bool { false }
    var deviceMotionUpdateInterval: TimeInterval = 0

    func startDeviceMotionUpdates(to queue: OperationQueue, withHandler handler: @escaping CMDeviceMotionHandler) {}
    func stopDeviceMotionUpdates() {}
}

private final class FakeCrownSequencer: CrownSequencerProtocol {
    var delegate: WKCrownDelegate?
    private(set) var didFocus = false

    func focus() {
        didFocus = true
    }

    func resignFocus() {
        didFocus = false
    }

    func simulateRotation(delta: Double) {
        delegate?.crownDidRotate?(nil, rotationalDelta: delta)
    }
}
