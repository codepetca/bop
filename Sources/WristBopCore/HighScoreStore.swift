import Foundation

/// Protocol for high score persistence
public protocol HighScoreStore: Sendable {
    /// Loads the current high score
    func loadHighScore() -> Int

    /// Saves a new high score
    func saveHighScore(_ score: Int)
}

/// UserDefaults-backed high score store
public final class UserDefaultsHighScoreStore: HighScoreStore, @unchecked Sendable {
    private let defaults: UserDefaults
    private let key: String

    public init(defaults: UserDefaults = .standard, key: String = GameConstants.highScoreKey) {
        self.defaults = defaults
        self.key = key
    }

    public func loadHighScore() -> Int {
        return defaults.integer(forKey: key)
    }

    public func saveHighScore(_ score: Int) {
        defaults.set(score, forKey: key)
    }
}
