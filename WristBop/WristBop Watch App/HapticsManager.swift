import WatchKit

final class HapticsManager {
    private let device: WKInterfaceDevice

    init(device: WKInterfaceDevice = .current()) {
        self.device = device
    }

    func play(_ event: GameFeedbackEvent) {
        guard let haptic = FeedbackConstants.hapticMapping[event] else { return }
        device.play(haptic)
    }
}
