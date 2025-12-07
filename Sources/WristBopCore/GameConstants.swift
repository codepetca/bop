import Foundation

/// Centralized gameplay tuning constants
public enum GameConstants {
    /// Starting time window per command (seconds)
    public static let initialTimePerCommand: TimeInterval = 3.0

    /// Minimum time window (speed floor)
    public static let minimumTimePerCommand: TimeInterval = 0.5

    /// Time decrease per difficulty ramp (seconds)
    public static let timeDecrementPerRamp: TimeInterval = 0.1

    /// Number of successful gestures before difficulty increases
    public static let successesPerDifficultyRamp: Int = 3

    /// UserDefaults key for high score persistence
    public static let highScoreKey: String = "WristBopHighScore"
}
