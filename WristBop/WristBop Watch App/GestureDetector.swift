import CoreMotion
import Foundation
import WatchKit
import WristBopCore

protocol GestureDetectorDelegate: AnyObject {
    func gestureDetector(_ detector: GestureDetector, didDetect gesture: GestureType)
}

protocol GestureDetecting: AnyObject {
    var delegate: GestureDetectorDelegate? { get set }
    func start()
    func stop()
    func setActiveCommand(_ command: GestureType?)
    func injectSample(_ sample: MotionSample)
}

protocol MotionManagerProtocol: AnyObject {
    var isDeviceMotionAvailable: Bool { get }
    var deviceMotionUpdateInterval: TimeInterval { get set }
    func startDeviceMotionUpdates(
        to queue: OperationQueue,
        withHandler handler: @escaping CMDeviceMotionHandler
    )
    func stopDeviceMotionUpdates()
}

protocol CrownSequencerProtocol: AnyObject {
    var delegate: WKCrownDelegate? { get set }
    func focus()
    func resignFocus()
}

struct MotionSample {
    let userAcceleration: CMAcceleration
    let rotationRate: CMRotationRate
    let timestamp: TimeInterval
}

final class GestureDetector: NSObject, GestureDetecting {
    weak var delegate: GestureDetectorDelegate?

    private let motionManager: MotionManagerProtocol
    private let crownSequencer: CrownSequencerProtocol?
    private let processingQueue: OperationQueue

    private var activeCommand: GestureType?
    private var hasEmittedForCommand = false
    private var samples: [MotionSample] = []
    private var shakePeaks: [TimeInterval] = []
    private var accumulatedCrownDelta: Double = 0

    init(
        motionManager: MotionManagerProtocol = CoreMotionManager(),
        crownSequencer: CrownSequencerProtocol? = CrownSequencerProvider.current
    ) {
        self.motionManager = motionManager
        self.crownSequencer = crownSequencer
        self.processingQueue = OperationQueue()
        self.processingQueue.maxConcurrentOperationCount = 1
        self.processingQueue.qualityOfService = .userInteractive
    }

    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }

        motionManager.deviceMotionUpdateInterval = GestureDetectorConstants.motionUpdateInterval
        motionManager.startDeviceMotionUpdates(to: processingQueue) { [weak self] motion, _ in
            guard let motion else { return }
            self?.handleMotion(motion)
        }

        crownSequencer?.delegate = self
        crownSequencer?.focus()
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
        crownSequencer?.resignFocus()
        samples.removeAll()
        shakePeaks.removeAll()
        accumulatedCrownDelta = 0
        hasEmittedForCommand = false
    }

    func setActiveCommand(_ command: GestureType?) {
        activeCommand = command
        hasEmittedForCommand = false
        shakePeaks.removeAll()
        accumulatedCrownDelta = 0
    }

    // MARK: - Testing hook

    func injectSample(_ sample: MotionSample) {
        processSample(sample)
    }

    // MARK: - Motion handling

    private func handleMotion(_ motion: CMDeviceMotion) {
        let sample = MotionSample(
            userAcceleration: motion.userAcceleration,
            rotationRate: motion.rotationRate,
            timestamp: motion.timestamp
        )
        processSample(sample)
    }

    private func processSample(_ sample: MotionSample) {
        guard let command = activeCommand, !hasEmittedForCommand else { return }

        samples.append(sample)
        trimSamples(olderThan: sample.timestamp - GestureDetectorConstants.sampleWindow)

        switch command {
        case .shake:
            if detectShake(from: sample) {
                emitDetection(for: .shake)
            }
        case .flickUp:
            if detectFlickUp(from: sample) {
                emitDetection(for: .flickUp)
            }
        case .twist:
            if detectTwist(from: sample) {
                emitDetection(for: .twist)
            }
        case .spinCrown:
            // Crown-driven; motion samples are ignored for this command.
            break
        }
    }

    private func trimSamples(olderThan cutoff: TimeInterval) {
        samples.removeAll { $0.timestamp < cutoff }
        shakePeaks.removeAll { $0 < cutoff }
    }

    // MARK: - Detection strategies

    private func detectShake(from sample: MotionSample) -> Bool {
        let acc = sample.userAcceleration
        let magnitude = sqrt(acc.x * acc.x + acc.y * acc.y + acc.z * acc.z)

        if magnitude >= GestureDetectorConstants.shakeAccelerationThreshold {
            let lastPeakTime = shakePeaks.last ?? -Double.infinity
            if sample.timestamp - lastPeakTime >= GestureDetectorConstants.shakePeakSeparation {
                shakePeaks.append(sample.timestamp)
            }
        }

        return shakePeaks.count >= GestureDetectorConstants.shakePeaksRequired
    }

    private func detectFlickUp(from sample: MotionSample) -> Bool {
        sample.userAcceleration.y >= GestureDetectorConstants.flickUpAccelerationThreshold
    }

    private func detectTwist(from sample: MotionSample) -> Bool {
        abs(sample.rotationRate.z) >= GestureDetectorConstants.twistRotationThreshold
    }

    private func emitDetection(for gesture: GestureType) {
        hasEmittedForCommand = true
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.delegate?.gestureDetector(self, didDetect: gesture)
        }
    }
}

// MARK: - Crown handling

extension GestureDetector: WKCrownDelegate {
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        guard let command = activeCommand, command == .spinCrown, !hasEmittedForCommand else { return }
        accumulatedCrownDelta += abs(rotationalDelta)

        if accumulatedCrownDelta >= GestureDetectorConstants.crownDeltaThreshold {
            emitDetection(for: .spinCrown)
        }
    }
}

// MARK: - Platform adapters

final class CoreMotionManager: MotionManagerProtocol {
    private let manager = CMMotionManager()

    var isDeviceMotionAvailable: Bool { manager.isDeviceMotionAvailable }

    var deviceMotionUpdateInterval: TimeInterval {
        get { manager.deviceMotionUpdateInterval }
        set { manager.deviceMotionUpdateInterval = newValue }
    }

    func startDeviceMotionUpdates(
        to queue: OperationQueue,
        withHandler handler: @escaping CMDeviceMotionHandler
    ) {
        manager.startDeviceMotionUpdates(to: queue, withHandler: handler)
    }

    func stopDeviceMotionUpdates() {
        manager.stopDeviceMotionUpdates()
    }
}

final class WatchCrownSequencer: CrownSequencerProtocol {
    private let sequencer: WKCrownSequencer

    init?(sequencer: WKCrownSequencer?) {
        guard let sequencer else { return nil }
        self.sequencer = sequencer
    }

    var delegate: WKCrownDelegate? {
        get { sequencer.delegate }
        set { sequencer.delegate = newValue }
    }

    func focus() {
        sequencer.focus()
    }

    func resignFocus() {
        sequencer.resignFocus()
    }
}

enum CrownSequencerProvider {
    static var current: CrownSequencerProtocol? {
        let sequencer = WKExtension.shared().rootInterfaceController?.crownSequencer
        return WatchCrownSequencer(sequencer: sequencer)
    }
}
