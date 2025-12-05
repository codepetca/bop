import Foundation

/// Value type holding the current game state
public struct GameState: Sendable {
    /// The current gesture command the player must perform
    public var currentCommand: GestureType?

    /// Current score (number of successful gestures)
    public var score: Int

    /// All-time high score
    public var highScore: Int

    /// Current time window per command (decreases as difficulty ramps)
    public var timePerCommand: TimeInterval

    /// Whether the game has ended
    public var isGameOver: Bool

    /// Whether a game is currently in progress
    public var isPlaying: Bool

    /// Internal count of successes since last difficulty ramp
    var successCount: Int

    /// Flag indicating that a speed-up cue should be triggered (haptic/sound)
    /// Only true when time actually decreases, not when already at minimum
    public var didTriggerSpeedUpCue: Bool

    /// Creates initial game state
    public init(
        currentCommand: GestureType? = nil,
        score: Int = 0,
        highScore: Int = 0,
        timePerCommand: TimeInterval = GameConstants.initialTimePerCommand,
        isGameOver: Bool = false,
        isPlaying: Bool = false,
        successCount: Int = 0,
        didTriggerSpeedUpCue: Bool = false
    ) {
        self.currentCommand = currentCommand
        self.score = score
        self.highScore = highScore
        self.timePerCommand = timePerCommand
        self.isGameOver = isGameOver
        self.isPlaying = isPlaying
        self.successCount = successCount
        self.didTriggerSpeedUpCue = didTriggerSpeedUpCue
    }
}
