import Foundation
@testable import WristBopCore

/// In-memory high score store for testing
final class InMemoryHighScoreStore: HighScoreStore, @unchecked Sendable {
    private var storedScore: Int = 0

    func loadHighScore() -> Int {
        return storedScore
    }

    func saveHighScore(_ score: Int) {
        storedScore = score
    }
}

/// Predictable command randomizer for testing
final class SequenceCommandRandomizer: CommandRandomizer, @unchecked Sendable {
    private let sequence: [GestureType]
    private var currentIndex: Int = 0

    init(sequence: [GestureType]) {
        self.sequence = sequence
    }

    func nextCommand(previous _: GestureType?) -> GestureType {
        guard !sequence.isEmpty else {
            return .shake
        }

        let command = sequence[currentIndex % sequence.count]
        currentIndex += 1
        return command
    }
}

/// Command randomizer that always returns the same command (useful for repeat checks)
final class FixedCommandRandomizer: CommandRandomizer, @unchecked Sendable {
    private let command: GestureType

    init(command: GestureType) {
        self.command = command
    }

    func nextCommand(previous _: GestureType?) -> GestureType {
        return command
    }
}
