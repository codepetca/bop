import WatchKit

/// Protocol for playing haptic feedback during gameplay.
/// Implementations trigger appropriate haptic patterns for game events.
protocol HapticsPlaying {
    /// Plays haptic feedback for the specified game event
    func play(_ event: GameFeedbackEvent)
}

final class HapticsManager: HapticsPlaying {
    private let device: WKInterfaceDevice

    init(device: WKInterfaceDevice = .current()) {
        self.device = device
    }

    func play(_ event: GameFeedbackEvent) {
        guard let haptic = FeedbackConstants.hapticMapping[event] else { return }
        device.play(haptic)
    }
}
