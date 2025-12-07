import AVFoundation

/// Protocol for playing sound effects during gameplay.
/// Implementations trigger appropriate sounds for game events.
protocol SoundPlaying {
    /// Plays sound effect for the specified game event
    func play(_ event: GameFeedbackEvent)
}

final class SoundManager: SoundPlaying {
    private var players: [GameFeedbackEvent: AVAudioPlayer] = [:]
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func play(_ event: GameFeedbackEvent) {
        guard let name = FeedbackConstants.soundAssetNames[event],
              let url = bundle.url(forResource: name, withExtension: "caf") ?? bundle.url(forResource: name, withExtension: "wav") else {
            return
        }

        if let player = players[event] {
            player.currentTime = 0
            player.play()
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[event] = player
            player.play()
        } catch {
            // If the asset can't be played, fail silently for now.
        }
    }
}
