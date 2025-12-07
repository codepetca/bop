import Foundation

/// Protocol for scheduling game command timers with tick updates and timeout callbacks.
/// Implementations should handle timer lifecycle and ensure callbacks are invoked appropriately.
protocol TimerScheduling: AnyObject {
    /// Starts a timer for the specified duration with regular tick callbacks.
    /// - Parameters:
    ///   - duration: Total time before timeout (seconds)
    ///   - tickInterval: How often to invoke onTick callback (seconds)
    ///   - onTick: Called periodically with remaining time
    ///   - onTimeout: Called once when duration expires
    func start(
        duration: TimeInterval,
        tickInterval: TimeInterval,
        onTick: @escaping (TimeInterval) -> Void,
        onTimeout: @escaping () -> Void
    )

    /// Cancels the running timer. Safe to call multiple times.
    func cancel()
}

final class SystemTimerScheduler: TimerScheduling {
    private var timer: Timer?
    private var startDate: Date?
    private var duration: TimeInterval = 0

    func start(
        duration: TimeInterval,
        tickInterval: TimeInterval,
        onTick: @escaping (TimeInterval) -> Void,
        onTimeout: @escaping () -> Void
    ) {
        cancel()
        self.duration = duration
        startDate = Date()

        timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            guard let self, let startDate else { return }
            let elapsed = Date().timeIntervalSince(startDate)
            let remaining = duration - elapsed
            if remaining <= 0 {
                self.cancel()
                onTimeout()
            } else {
                onTick(remaining)
            }
        }
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
        startDate = nil
    }
}
