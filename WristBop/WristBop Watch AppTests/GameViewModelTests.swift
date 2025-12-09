import Foundation
import Testing
@testable import WristBop_Watch_App
import WristBopCore

@MainActor
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

    @Test("Wrong gesture is silently ignored")
    func testWrongGestureIgnored() {
        let detector = FakeDetector()
        let timers = FakeTimerScheduler()
        let haptics = FakeHaptics()
        let sounds = FakeSounds()
        let randomizer = SequenceCommandRandomizer(sequence: [.shake, .flickUp])
        let viewModel = GameViewModel(
            haptics: haptics,
            sounds: sounds,
            detector: detector,
            timerScheduler: timers,
            commandRandomizer: randomizer,
            skipCountdown: true
        )

        viewModel.startGame()
        let correctCommand = viewModel.currentCommand!
        let wrongCommand: GestureType = (correctCommand == .shake) ? .flickUp : .shake
        let initialScore = viewModel.score

        // Send wrong gesture
        viewModel.handleGesture(wrongCommand)

        // Verify no state changes occurred
        #expect(viewModel.score == initialScore)
        #expect(viewModel.currentCommand == correctCommand)
        #expect(!haptics.playedEvents.contains(.success))
        #expect(!sounds.playedEvents.contains(.success))
        #expect(timers.startedCount == 1) // Only initial start, no restart
    }

    @Test("Timeout ends game and clears command")
    func testTimeoutTriggeredByScheduler() {
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
        timers.triggerTimeout()

        #expect(viewModel.isGameOver == true)
        #expect(viewModel.isPlaying == false)
        #expect(detector.lastActiveCommand == nil)
        #expect(haptics.playedEvents.contains(.failure))
        #expect(sounds.playedEvents.contains(.failure))
        #expect(timers.cancelledCount > 0)
    }

    @Test("Reset restarts detector and timer and clears transient flags")
    func testResetGameRestartsLoop() {
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
        timers.triggerTimeout()

        viewModel.resetGame()

        #expect(detector.startCount == 2) // initial start + reset start
        #expect(detector.lastActiveCommand != nil)
        #expect(timers.startedCount == 2)
        #expect(viewModel.isPlaying == true)
        #expect(viewModel.isGameOver == false)
        #expect(viewModel.showingSpeedUpMessage == false)
    }

    @Test("Speed-up cue triggers feedback and pauses timer")
    func testSpeedUpCuePlaysFeedback() {
        let detector = FakeDetector()
        let timers = FakeTimerScheduler()
        let haptics = FakeHaptics()
        let sounds = FakeSounds()
        let randomizer = SequenceCommandRandomizer(sequence: [.shake, .flickUp, .twist])
        let viewModel = GameViewModel(
            haptics: haptics,
            sounds: sounds,
            detector: detector,
            timerScheduler: timers,
            commandRandomizer: randomizer,
            skipCountdown: true
        )

        viewModel.startGame()

        for _ in 0..<GameConstants.successesPerDifficultyRamp {
            guard let command = viewModel.currentCommand else { break }
            viewModel.handleGesture(command)
        }

        #expect(haptics.playedEvents.contains(.speedUp))
        #expect(sounds.playedEvents.contains(.speedUp))
        #expect(viewModel.didSpeedUp == true)
        #expect(viewModel.showingSpeedUpMessage == true)
        #expect(timers.cancelledCount >= 3) // initial start + each restart + pause
    }

    @Test("Gestures blocked during speed-up message")
    func testGestureBlockedDuringSpeedUp() {
        let detector = FakeDetector()
        let timers = FakeTimerScheduler()
        let haptics = FakeHaptics()
        let sounds = FakeSounds()
        let randomizer = SequenceCommandRandomizer(sequence: [.shake, .flickUp, .twist, .spinCrown])
        let viewModel = GameViewModel(
            haptics: haptics,
            sounds: sounds,
            detector: detector,
            timerScheduler: timers,
            commandRandomizer: randomizer,
            skipCountdown: true
        )

        viewModel.startGame()

        // Trigger speed-up
        for _ in 0..<GameConstants.successesPerDifficultyRamp {
            guard let command = viewModel.currentCommand else { break }
            viewModel.handleGesture(command)
        }

        #expect(viewModel.showingSpeedUpMessage == true)
        let scoreBeforeBlocked = viewModel.score
        let successCountBefore = haptics.playedEvents.filter { $0 == .success }.count

        // Try to send gesture while speed-up showing
        if let command = viewModel.currentCommand {
            viewModel.handleGesture(command)
        }

        // Verify gesture was ignored
        #expect(viewModel.score == scoreBeforeBlocked)
        let successCountAfter = haptics.playedEvents.filter { $0 == .success }.count
        #expect(successCountAfter == successCountBefore)
    }

    @Test("Countdown shows 3-2-1 then starts the game")
    func testCountdownSequenceStartsGame() async throws {
        let detector = FakeDetector()
        let timers = FakeTimerScheduler()
        let haptics = FakeHaptics()
        let sounds = FakeSounds()
        let viewModel = GameViewModel(
            haptics: haptics,
            sounds: sounds,
            detector: detector,
            timerScheduler: timers,
            skipCountdown: false,
            countdownStepDuration: 10_000 // Fast countdown for testing
        )

        viewModel.startGame()

        // Countdown starts immediately with "3"
        try await Task.sleep(nanoseconds: 1_000)
        #expect(viewModel.showingCountdown == true)
        #expect(viewModel.countdownValue == 3)
        #expect(timers.startedCount == 0) // game timer not yet started

        // Advance through countdown steps
        try await Task.sleep(nanoseconds: 15_000)
        #expect(viewModel.countdownValue == 2)

        try await Task.sleep(nanoseconds: 15_000)
        #expect(viewModel.countdownValue == 1)

        try await Task.sleep(nanoseconds: 15_000)
        #expect(viewModel.showingCountdown == false)
        #expect(viewModel.isPlaying == true)
        #expect(timers.startedWithDuration == GameConstants.initialTimePerCommand)
    }

    @Test("Countdown can be cancelled")
    func testCountdownCancellation() async throws {
        let detector = FakeDetector()
        let timers = FakeTimerScheduler()
        let haptics = FakeHaptics()
        let sounds = FakeSounds()
        let viewModel = GameViewModel(
            haptics: haptics,
            sounds: sounds,
            detector: detector,
            timerScheduler: timers,
            skipCountdown: false,
            countdownStepDuration: 50_000
        )

        viewModel.startGame()
        #expect(viewModel.showingCountdown == true)

        // End game during countdown
        viewModel.endGame()

        // Verify timer was cancelled
        #expect(timers.cancelledCount == 0) // game timer never started
        #expect(viewModel.showingCountdown == false)
        #expect(viewModel.countdownValue == nil)
        #expect(viewModel.isPlaying == false)
    }

    @Test("Game timer reuses scheduler after countdown")
    func testTimerReuseAfterCountdown() {
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

        // Start game with skip countdown (uses game timer directly)
        viewModel.startGame()
        #expect(timers.startedCount == 1)
        #expect(timers.startedWithDuration == GameConstants.initialTimePerCommand)

        // Simulate correct gesture to restart timer
        if let command = viewModel.currentCommand {
            viewModel.handleGesture(command)
        }

        // Verify timer was restarted properly (cancelled then started again)
        #expect(timers.cancelledCount == 1)
        #expect(timers.startedCount == 2)
    }

    @Test("Skip countdown flag bypasses countdown timer")
    func testSkipCountdownBypassesTimer() {
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

        // Verify no countdown shown
        #expect(viewModel.showingCountdown == false)
        #expect(viewModel.countdownValue == nil)

        // Verify game started immediately with game timer
        #expect(viewModel.isPlaying == true)
        #expect(detector.started == true)
        #expect(timers.startedWithDuration == GameConstants.initialTimePerCommand)
    }
}

// MARK: - Fakes

private final class FakeDetector: GestureDetecting {
    weak var delegate: GestureDetectorDelegate?
    var started = false
    var stopped = false
    var startCount = 0
    var stopCount = 0
    var lastActiveCommand: GestureType?
    var debugUpdateHandler: ((GestureDebugInfo) -> Void)?

    func start() {
        started = true
        startCount += 1
    }

    func stop() {
        stopped = true
        stopCount += 1
    }

    func setActiveCommand(_ command: GestureType?) {
        lastActiveCommand = command
    }

    func injectSample(_ sample: MotionSample) {}
}

private final class FakeTimerScheduler: TimerScheduling {
    var startedWithDuration: TimeInterval?
    var startedCount = 0
    var cancelledCount = 0
    private(set) var lastTickInterval: TimeInterval?
    private var onTickHandler: ((TimeInterval) -> Void)?
    private var onTimeoutHandler: (() -> Void)?
    private var isRunning = false

    func start(
        duration: TimeInterval,
        tickInterval: TimeInterval,
        onTick: @escaping (TimeInterval) -> Void,
        onTimeout: @escaping () -> Void
    ) {
        startedWithDuration = duration
        startedCount += 1
        lastTickInterval = tickInterval
        onTickHandler = onTick
        onTimeoutHandler = onTimeout
        isRunning = true
    }

    func cancel() {
        if isRunning {
            cancelledCount += 1
            isRunning = false
        }
    }

    func triggerTimeout() {
        onTimeoutHandler?()
    }

    func tick(_ remaining: TimeInterval) {
        onTickHandler?(remaining)
    }
}

private final class FakeHaptics: HapticsPlaying {
    var playedEvents: [GameFeedbackEvent] = []
    func play(_ event: GameFeedbackEvent) {
        playedEvents.append(event)
    }
}

private final class FakeSounds: SoundPlaying {
    var playedEvents: [GameFeedbackEvent] = []
    func play(_ event: GameFeedbackEvent) {
        playedEvents.append(event)
    }
}

private final class SequenceCommandRandomizer: CommandRandomizer, @unchecked Sendable {
    private let sequence: [GestureType]
    private var currentIndex: Int = 0

    init(sequence: [GestureType]) {
        self.sequence = sequence
    }

    func nextCommand(excluding: GestureType?) -> GestureType {
        guard !sequence.isEmpty else { return .shake }
        let command = sequence[currentIndex % sequence.count]
        currentIndex += 1
        return command
    }
}
