import Foundation

/// Protocol defining the game engine interface
public protocol GameEngineProtocol: Sendable {
    /// Current game state
    var state: GameState { get }

    /// Starts a new game
    func startGame()

    /// Ends the current game
    func endGame()

    /// Handles a successful gesture match
    /// - Parameter gesture: The gesture that was performed
    func handleGestureMatch(_ gesture: GestureType)

    /// Handles a timeout (ends the game)
    func handleTimeout()

    /// Generates and returns the next command
    /// - Returns: The next gesture command
    func nextCommand() -> GestureType
}

/// Concrete implementation of the game engine
public final class GameEngine: GameEngineProtocol, @unchecked Sendable {
    private var _state: GameState
    private let commandRandomizer: CommandRandomizer
    private let highScoreStore: HighScoreStore

    public var state: GameState {
        return _state
    }

    public init(
        commandRandomizer: CommandRandomizer,
        highScoreStore: HighScoreStore
    ) {
        self.commandRandomizer = commandRandomizer
        self.highScoreStore = highScoreStore
        self._state = GameState(highScore: highScoreStore.loadHighScore())
    }

    public func startGame() {
        // Reset state to initial values
        _state = GameState(
            currentCommand: nil,
            score: 0,
            highScore: highScoreStore.loadHighScore(),
            timePerCommand: GameConstants.initialTimePerCommand,
            isGameOver: false,
            isPlaying: true,
            successCount: 0,
            didTriggerSpeedUpCue: false
        )

        // Generate first command
        _state.currentCommand = nextCommand()
    }

    public func endGame() {
        _state.isPlaying = false
        _state.isGameOver = true

        // Update high score if needed
        if _state.score > _state.highScore {
            _state.highScore = _state.score
            highScoreStore.saveHighScore(_state.score)
        }
    }

    public func handleGestureMatch(_ gesture: GestureType) {
        guard _state.isPlaying, !_state.isGameOver else { return }
        guard let currentCommand = _state.currentCommand else { return }

        // Only process if gesture matches current command
        guard gesture == currentCommand else {
            // Wrong gestures are ignored (timeout-only failure)
            return
        }

        // Increment score
        _state.score += 1
        _state.successCount += 1

        // Clear speed-up cue flag (will be set if difficulty ramps)
        _state.didTriggerSpeedUpCue = false

        // Check if we should ramp difficulty
        if _state.successCount >= GameConstants.successesPerDifficultyRamp {
            _state.successCount = 0

            let previousTime = _state.timePerCommand
            let newTime = max(
                GameConstants.minimumTimePerCommand,
                _state.timePerCommand - GameConstants.timeDecrementPerRamp
            )

            _state.timePerCommand = newTime

            // Only trigger speed-up cue if time actually decreased
            if newTime < previousTime {
                _state.didTriggerSpeedUpCue = true
            }
        }

        // Generate next command
        _state.currentCommand = nextCommand()
    }

    public func handleTimeout() {
        guard _state.isPlaying, !_state.isGameOver else { return }
        endGame()
    }

    public func nextCommand() -> GestureType {
        return commandRandomizer.nextCommand(previous: _state.currentCommand)
    }
}
