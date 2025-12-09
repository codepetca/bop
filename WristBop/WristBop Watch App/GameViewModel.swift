//
//  GameViewModel.swift
//  WristBop Watch App
//
//  Created by Claude Code on 2025-12-05.
//

import SwiftUI
import CoreMotion
import Combine
import WristBopCore

#if DEBUG_OVERLAY
struct DebugOverlayState {
    var acceleration: CMAcceleration?
    var rotationRate: CMRotationRate?
    var crownAccumulatedDelta: Double = 0
    var activeCommand: GestureType?
    var lastDetectedGesture: GestureType?
    var detectorActive: Bool = false
}
#endif

@MainActor
class GameViewModel: ObservableObject {
    // Published properties for UI
    @Published var currentCommand: GestureType?
    @Published var score: Int = 0
    @Published var highScore: Int = 0
    @Published var lastScore: Int = 0
    @Published var timeRemaining: TimeInterval = 0
    @Published var maxTimeForCurrentCommand: TimeInterval = GameConstants.initialTimePerCommand
    @Published var isPlaying: Bool = false
    @Published var isGameOver: Bool = false
    @Published var didSpeedUp: Bool = false
    @Published var showingSpeedUpMessage: Bool = false
    @Published var canTapToSkipGameOver: Bool = false
    @Published var showingCountdown: Bool = false
    @Published var countdownValue: Int?
#if DEBUG_OVERLAY
    @Published var debugOverlayState = DebugOverlayState()
#endif

    // Game engine
    private var engine: GameEngine
    private let haptics: any HapticsPlaying
    private let sounds: any SoundPlaying
    private let detector: GestureDetecting
    private let timerScheduler: TimerScheduling
    private let tickInterval: TimeInterval
    private let speedUpMessageDuration: UInt64
    private let countdownStepDuration: UInt64

    // Task management for async operations
    private var speedUpTask: Task<Void, Never>?
    private var countdownTask: Task<Void, Never>?
    private var gameOverSkipTask: Task<Void, Never>?
    private var gameOverAutoReturnTask: Task<Void, Never>?

    init(
        haptics: any HapticsPlaying,
        sounds: any SoundPlaying,
        detector: GestureDetecting,
        timerScheduler: TimerScheduling,
        commandRandomizer: CommandRandomizer = SystemCommandRandomizer(),
        highScoreStore: HighScoreStore = UserDefaultsHighScoreStore(),
        tickInterval: TimeInterval = 0.05,
        speedUpMessageDuration: UInt64 = 2_000_000_000,
        countdownStepDuration: UInt64 = 1_000_000_000,
        skipCountdown: Bool = false
    ) {
        self.engine = GameEngine(
            commandRandomizer: commandRandomizer,
            highScoreStore: highScoreStore
        )
        self.haptics = haptics
        self.sounds = sounds
        self.detector = detector
        self.timerScheduler = timerScheduler
        self.tickInterval = tickInterval
        self.highScore = engine.state.highScore
        self.lastScore = UserDefaults.standard.integer(forKey: "WristBopLastScore")
        self.speedUpMessageDuration = speedUpMessageDuration
        self.countdownStepDuration = countdownStepDuration
        self.shouldSkipCountdown = skipCountdown

        // Set detector delegate once - it never changes during the view model's lifetime
        detector.delegate = self
#if DEBUG_OVERLAY
        detector.debugUpdateHandler = { [weak self] info in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.debugOverlayState.acceleration = info.acceleration
                self.debugOverlayState.rotationRate = info.rotationRate
                self.debugOverlayState.crownAccumulatedDelta = info.crownAccumulatedDelta
                self.debugOverlayState.activeCommand = info.activeCommand
            }
        }
#endif
    }

    convenience init(skipCountdown: Bool = false) {
        self.init(
            haptics: HapticsManager(),
            sounds: SoundManager(),
            detector: GestureDetector(),
            timerScheduler: SystemTimerScheduler(),
            commandRandomizer: SystemCommandRandomizer(),
            highScoreStore: UserDefaultsHighScoreStore(),
            skipCountdown: skipCountdown
        )
    }

    private let shouldSkipCountdown: Bool

    // MARK: - Game Control

    func startGame() {
        resetTransientUIState()

        if shouldSkipCountdown {
            actuallyStartGame()
        } else {
            // Start countdown instead of game immediately
            startCountdown()
        }
    }

    private func actuallyStartGame() {
        engine.startGame()
        updateFromEngineState()
        detector.start()
#if DEBUG_OVERLAY
        debugOverlayState.detectorActive = true
#endif
        detector.setActiveCommand(engine.state.currentCommand)
        startTimer()
    }

    func resetGame() {
        resetTransientUIState()
        stopTimer()
        detector.stop()
#if DEBUG_OVERLAY
        debugOverlayState.detectorActive = false
#endif
        detector.setActiveCommand(nil)
        engine.startGame()
        updateFromEngineState()
        detector.setActiveCommand(engine.state.currentCommand)
        detector.start()
#if DEBUG_OVERLAY
        debugOverlayState.detectorActive = true
#endif
        startTimer()
    }

    func endGame() {
        // Cancel any pending tasks before ending
        speedUpTask?.cancel()
        speedUpTask = nil
        cancelCountdown()

        stopTimer()
        detector.stop()
#if DEBUG_OVERLAY
        debugOverlayState.detectorActive = false
#endif
        engine.endGame()
        updateFromEngineState()
    }

    // MARK: - Gesture Handling

    func handleGesture(_ gesture: GestureType) {
        // Defensive checks to prevent any state changes during invalid states
        guard isPlaying else { return }
        guard !isGameOver else { return }
        guard !showingSpeedUpMessage else { return }
        guard !showingCountdown else { return }
        guard let currentCommand = currentCommand else { return }

        // Only process if it's the correct gesture
        guard gesture == currentCommand else { return }

#if DEBUG_OVERLAY
        debugOverlayState.lastDetectedGesture = gesture
#endif

        let previousScore = engine.state.score

        engine.handleGestureMatch(gesture)
        updateFromEngineState()

        // Only restart timer if score actually increased (correct gesture)
        if engine.state.score > previousScore {
            // Check if we just triggered a speed-up
            if engine.state.didTriggerSpeedUpCue {
                haptics.play(.speedUp)
                sounds.play(.speedUp)
                // Pause game and show speed-up message
                showSpeedUpMessage()
            } else {
                haptics.play(.success)
                sounds.play(.success)
                // Restart timer with new time per command
                startTimer()
            }
        }
    }

    // MARK: - Timer Management

    private func startTimer() {
        stopTimer()

        // Capture the current time window for this command
        maxTimeForCurrentCommand = engine.state.timePerCommand
        haptics.play(.tick)
        sounds.play(.tick)

        timerScheduler.start(
            duration: engine.state.timePerCommand,
            tickInterval: tickInterval,
            onTick: { [weak self] remaining in
                self?.timeRemaining = remaining
            },
            onTimeout: { [weak self] in
                self?.handleTimeout()
            }
        )
    }

    private func stopTimer() {
        timerScheduler.cancel()
    }

    private func handleTimeout() {
        stopTimer()
        detector.setActiveCommand(nil)
        detector.stop()
#if DEBUG_OVERLAY
        debugOverlayState.detectorActive = false
#endif

        // Save last score before ending game
        lastScore = engine.state.score
        UserDefaults.standard.set(lastScore, forKey: "WristBopLastScore")

        engine.handleTimeout()
        updateFromEngineState()
        canTapToSkipGameOver = false
        haptics.play(.failure)
        sounds.play(.failure)

        // After 3 seconds, allow tap to skip
        gameOverSkipTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            await MainActor.run {
                self.canTapToSkipGameOver = true
            }
        }

        // Auto-return to menu after 8 seconds total
        gameOverAutoReturnTask = Task {
            try? await Task.sleep(nanoseconds: 8_000_000_000) // 8 seconds
            await MainActor.run {
                // Reset to menu
                self.returnToMenu()
            }
        }
    }

    func returnToMenu() {
        // Cancel any pending game-over tasks
        gameOverSkipTask?.cancel()
        gameOverSkipTask = nil
        gameOverAutoReturnTask?.cancel()
        gameOverAutoReturnTask = nil

        isPlaying = false
        isGameOver = false
        canTapToSkipGameOver = false
#if DEBUG_OVERLAY
        debugOverlayState.detectorActive = false
        debugOverlayState.activeCommand = nil
#endif
    }

    // MARK: - Countdown Management

    private func startCountdown() {
        cancelCountdown()
        showingCountdown = true
        countdownTask = Task { [weak self] in
            guard let self else { return }

            for value in stride(from: 3, through: 1, by: -1) {
                if Task.isCancelled { return }
                await MainActor.run {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        self.countdownValue = value
                    }
                }

                do {
                    try await Task.sleep(nanoseconds: countdownStepDuration)
                } catch {
                    return
                }
            }

            if Task.isCancelled { return }

            await MainActor.run {
                self.countdownTask = nil
                self.showingCountdown = false
                self.countdownValue = nil
                self.actuallyStartGame()
            }
        }
    }

    private func cancelCountdown() {
        countdownTask?.cancel()
        countdownTask = nil
        showingCountdown = false
        countdownValue = nil
    }

    private func showSpeedUpMessage() {
        stopTimer()
        showingSpeedUpMessage = true

        // Show message for 2 seconds, then resume
        speedUpTask = Task {
            try? await Task.sleep(nanoseconds: speedUpMessageDuration)
            await MainActor.run {
                self.showingSpeedUpMessage = false
                self.startTimer()
            }
        }
    }

    // MARK: - State Synchronization

    private func updateFromEngineState() {
        let state = engine.state

        currentCommand = state.currentCommand
        score = state.score
        highScore = state.highScore
        isPlaying = state.isPlaying
        isGameOver = state.isGameOver
        timeRemaining = state.timePerCommand
#if DEBUG_OVERLAY
        debugOverlayState.activeCommand = state.currentCommand
#endif

        // Set speed-up flag (used for UI indication)
        didSpeedUp = state.didTriggerSpeedUpCue

        // Keep detector in sync with active command when playing
        if state.isPlaying, !state.isGameOver {
            detector.setActiveCommand(state.currentCommand)
        } else {
            detector.setActiveCommand(nil)
        }
    }

    private func resetTransientUIState() {
        // Cancel all pending async tasks
        speedUpTask?.cancel()
        speedUpTask = nil
        cancelCountdown()
        gameOverSkipTask?.cancel()
        gameOverSkipTask = nil
        gameOverAutoReturnTask?.cancel()
        gameOverAutoReturnTask = nil

        showingSpeedUpMessage = false
        showingCountdown = false
        canTapToSkipGameOver = false
        didSpeedUp = false
        isGameOver = false
#if DEBUG_OVERLAY
        debugOverlayState.lastDetectedGesture = nil
        debugOverlayState.acceleration = nil
        debugOverlayState.rotationRate = nil
        debugOverlayState.crownAccumulatedDelta = 0
#endif
    }

    @MainActor deinit {
        // Clean up timers and tasks on teardown
        timerScheduler.cancel()

        // Cancel all pending tasks
        speedUpTask?.cancel()
        countdownTask?.cancel()
        gameOverSkipTask?.cancel()
        gameOverAutoReturnTask?.cancel()
    }
}

extension GameViewModel: GestureDetectorDelegate {
    func gestureDetector(_ detector: GestureDetector, didDetect gesture: GestureType) {
        handleGesture(gesture)
    }
}
