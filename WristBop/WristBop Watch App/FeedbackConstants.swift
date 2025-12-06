import WatchKit

enum GameFeedbackEvent {
    case tick
    case success
    case failure
    case speedUp
}

enum FeedbackConstants {
    // Map gameplay events to watch haptic types
    static let hapticMapping: [GameFeedbackEvent: WKHapticType] = [
        .tick: .click,
        .success: .success,
        .failure: .failure,
        .speedUp: .directionUp
    ]

    // Map events to optional bundled sound asset names (add files later as needed)
    static let soundAssetNames: [GameFeedbackEvent: String] = [
        .tick: "tick",
        .success: "success",
        .failure: "failure",
        .speedUp: "speedup"
    ]
}
