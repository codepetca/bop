import Testing
@testable import WristBop_Watch_App
import WristBopCore

@Suite("GameViewModel")
struct GameViewModelTests {

    @Test("Start game activates detector and timer with initial duration")
    func testStartGameSetsCommandAndTimer() {
        let detector = FakeDetector()
        let timers = FakeTimerScheduler()
        let haptics = FakeHaptics()
        let sounds = FakeSounds()
        let viewModel = GameViewModel(
            haptics: haptics,
            sounds: sounds,
            detector: detector,
            timerScheduler: timers,
            skipCountdown: true
        )

        viewModel.startGame()

        #expect(detector.started == true)
        #expect(detector.lastActiveCommand != nil)
        #expect(timers.startedWithDuration == GameConstants.initialTimePerCommand)
        #expect(haptics.playedEvents.contains(.tick))
        #expect(sounds.playedEvents.contains(.tick))
    }

    @Test("Correct gesture restarts timer and plays success feedback")
    func testGestureMatch() {
        let detector = FakeDetector()
        let timers = FakeTimerScheduler()
        let haptics = FakeHaptics()
        let sounds = FakeSounds()
        let viewModel = GameViewModel(
            haptics: haptics,
            sounds: sounds,
            detector: detector,
            timerScheduler: timers,
            skipCountdown: true
        )

        viewModel.startGame()
        let command = viewModel.currentCommand!

        // Simulate gesture detection
        viewModel.handleGesture(command)

        #expect(haptics.playedEvents.contains(.success))
        #expect(sounds.playedEvents.contains(.success))
        #expect(timers.cancelledCount == 1)
        #expect(timers.startedCount == 2) // initial + restart
        #expect(detector.lastActiveCommand != nil)
    }

    @Test("Timeout plays failure and clears active command")
    func testTimeout() {
        let detector = FakeDetector()
        let timers = FakeTimerScheduler()
        let haptics = FakeHaptics()
        let sounds = FakeSounds()
        let viewModel = GameViewModel(
            haptics: haptics,
            sounds: sounds,
            detector: detector,
            timerScheduler: timers,
            skipCountdown: true
        )

        viewModel.startGame()
        viewModel.handleTimeout()

        #expect(haptics.playedEvents.contains(.failure))
        #expect(sounds.playedEvents.contains(.failure))
        #expect(detector.lastActiveCommand == nil)
    }
}

// MARK: - Fakes

private final class FakeDetector: GestureDetecting {
    weak var delegate: GestureDetectorDelegate?
    var started = false
    var stopped = false
    var lastActiveCommand: GestureType?

    func start() { started = true }
    func stop() { stopped = true }

    func setActiveCommand(_ command: GestureType?) {
        lastActiveCommand = command
    }

    func injectSample(_ sample: MotionSample) {}
}

private final class FakeTimerScheduler: TimerScheduling {
    var startedWithDuration: TimeInterval?
    var startedCount = 0
    var cancelledCount = 0

    func start(
        duration: TimeInterval,
        tickInterval: TimeInterval,
        onTick: @escaping (TimeInterval) -> Void,
        onTimeout: @escaping () -> Void
    ) {
        startedWithDuration = duration
        startedCount += 1
    }

    func cancel() {
        cancelledCount += 1
    }
}

private final class FakeHaptics: HapticsManager {
    var playedEvents: [GameFeedbackEvent] = []
    override func play(_ event: GameFeedbackEvent) {
        playedEvents.append(event)
    }
}

private final class FakeSounds: SoundManager {
    var playedEvents: [GameFeedbackEvent] = []
    override func play(_ event: GameFeedbackEvent) {
        playedEvents.append(event)
    }
}
