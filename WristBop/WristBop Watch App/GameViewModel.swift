//
//  GameViewModel.swift
//  WristBop Watch App
//
//  Created by Claude Code on 2025-12-05.
//

import SwiftUI
import Combine
import WristBopCore

@MainActor
class GameViewModel: ObservableObject {
    // Published properties for UI
    @Published var currentCommand: GestureType?
    @Published var score: Int = 0
    @Published var highScore: Int = 0
    @Published var lastScore: Int = 0
    @Published var timeRemaining: TimeInterval = 0
    @Published var maxTimeForCurrentCommand: TimeInterval = 2.4
    @Published var isPlaying: Bool = false
    @Published var isGameOver: Bool = false
    @Published var didSpeedUp: Bool = false
    @Published var showingSpeedUpMessage: Bool = false
    @Published var canTapToSkipGameOver: Bool = false
    @Published var showingCountdown: Bool = false
    @Published var countdownTimeRemaining: TimeInterval = 0
    @Published var showingGo: Bool = false

    // Game engine
    private var engine: GameEngine

    // Timer management
    nonisolated(unsafe) private var timer: Timer?
    private var commandStartTime: Date?
    nonisolated(unsafe) private var countdownTimer: Timer?
    private var countdownStartTime: Date?

    init() {
        self.engine = GameEngine(
            commandRandomizer: SystemCommandRandomizer(),
            highScoreStore: UserDefaultsHighScoreStore()
        )
        self.highScore = engine.state.highScore
        self.lastScore = UserDefaults.standard.integer(forKey: "WristBopLastScore")
    }

    // MARK: - Game Control

    func startGame() {
        // Start countdown instead of game immediately
        startCountdown()
    }

    private func actuallyStartGame() {
        engine.startGame()
        updateFromEngineState()
        startTimer()
    }

    func resetGame() {
        stopTimer()
        engine.startGame()
        updateFromEngineState()
        startTimer()
    }

    func endGame() {
        stopTimer()
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

        let previousScore = engine.state.score

        engine.handleGestureMatch(gesture)
        updateFromEngineState()

        // Only restart timer if score actually increased (correct gesture)
        if engine.state.score > previousScore {
            // Check if we just triggered a speed-up
            if engine.state.didTriggerSpeedUpCue {
                // Pause game and show speed-up message
                showSpeedUpMessage()
            } else {
                // Restart timer with new time per command
                startTimer()
            }
        }
    }

    // MARK: - Timer Management

    private func startTimer() {
        stopTimer()
        commandStartTime = Date()

        // Capture the current time window for this command
        maxTimeForCurrentCommand = engine.state.timePerCommand

        // Start a timer that fires frequently to update UI
        // Use RunLoop.main to ensure timer runs on main thread
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.updateTimer()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        commandStartTime = nil
    }

    private func updateTimer() {
        guard let startTime = commandStartTime else { return }

        let elapsed = Date().timeIntervalSince(startTime)
        let remaining = engine.state.timePerCommand - elapsed

        if remaining <= 0 {
            // Time's up!
            handleTimeout()
        } else {
            timeRemaining = remaining
        }
    }

    private func handleTimeout() {
        stopTimer()

        // Save last score before ending game
        lastScore = engine.state.score
        UserDefaults.standard.set(lastScore, forKey: "WristBopLastScore")

        engine.handleTimeout()
        updateFromEngineState()
        canTapToSkipGameOver = false

        // After 3 seconds, allow tap to skip
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            await MainActor.run {
                self.canTapToSkipGameOver = true
            }
        }

        // Auto-return to menu after 8 seconds total
        Task {
            try? await Task.sleep(nanoseconds: 8_000_000_000) // 8 seconds
            await MainActor.run {
                // Reset to menu
                self.returnToMenu()
            }
        }
    }

    func returnToMenu() {
        isPlaying = false
        isGameOver = false
        canTapToSkipGameOver = false
    }

    // MARK: - Countdown Management

    private func startCountdown() {
        stopCountdownTimer()
        showingCountdown = true
        showingGo = false
        countdownTimeRemaining = 3.0
        countdownStartTime = Date()

        // Start a timer that fires frequently to update countdown UI
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.updateCountdownTimer()
            }
        }
    }

    private func stopCountdownTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        countdownStartTime = nil
    }

    private func updateCountdownTimer() {
        guard let startTime = countdownStartTime else { return }

        let elapsed = Date().timeIntervalSince(startTime)
        let remaining = 3.0 - elapsed

        if remaining <= 0 {
            // Countdown complete - show "GO!" then start game
            handleCountdownComplete()
        } else {
            countdownTimeRemaining = remaining
        }
    }

    private func handleCountdownComplete() {
        stopCountdownTimer()
        showingGo = true

        // Show "GO!" for 0.5 seconds, then start game
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            await MainActor.run {
                self.showingCountdown = false
                self.showingGo = false
                self.actuallyStartGame()
            }
        }
    }

    private func showSpeedUpMessage() {
        stopTimer()
        showingSpeedUpMessage = true

        // Show message for 2 seconds, then resume
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
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

        // Set speed-up flag (used for UI indication)
        didSpeedUp = state.didTriggerSpeedUpCue
    }

    deinit {
        // Invalidate timers directly since deinit can't be MainActor
        timer?.invalidate()
        countdownTimer?.invalidate()
    }
}
