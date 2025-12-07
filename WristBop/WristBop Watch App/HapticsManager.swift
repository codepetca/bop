import WatchKit

/// Abstraction for playing haptic feedback (protocol to allow testing doubles)
protocol HapticsPlaying {
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
