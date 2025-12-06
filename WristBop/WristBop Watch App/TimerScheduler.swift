import Foundation

protocol TimerScheduling: AnyObject {
    func start(
        duration: TimeInterval,
        tickInterval: TimeInterval,
        onTick: @escaping (TimeInterval) -> Void,
        onTimeout: @escaping () -> Void
    )
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
