import Foundation

/// Protocol for generating random gesture commands
public protocol CommandRandomizer: Sendable {
    /// Generates a random gesture command.
    /// - Parameter previous: The previously issued command (if any), provided for context.
    func nextCommand(previous: GestureType?) -> GestureType
}

/// System implementation using SystemRandomNumberGenerator
public struct SystemCommandRandomizer: CommandRandomizer {
    public init() {}

    public func nextCommand(previous _: GestureType?) -> GestureType {
        // Choose uniformly from all gestures; repeats are allowed.
        return GestureType.allCases.randomElement()!
    }
}
