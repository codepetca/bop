import Foundation

/// Protocol for generating random gesture commands
public protocol CommandRandomizer: Sendable {
    /// Generates a random gesture command, excluding the previous command
    /// - Parameter excluding: The previous command to exclude (optional)
    /// - Returns: A random GestureType different from the excluded one
    func nextCommand(excluding: GestureType?) -> GestureType
}

/// System implementation using SystemRandomNumberGenerator
public struct SystemCommandRandomizer: CommandRandomizer {
    public init() {}

    public func nextCommand(excluding: GestureType?) -> GestureType {
        let allGestures = GestureType.allCases

        guard let excluding = excluding else {
            // No exclusion, return any random gesture
            return allGestures.randomElement()!
        }

        // Filter out the excluded gesture
        let available = allGestures.filter { $0 != excluding }
        return available.randomElement()!
    }
}
