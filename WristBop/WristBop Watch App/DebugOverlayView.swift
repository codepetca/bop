import SwiftUI
import CoreMotion
import WristBopCore

#if DEBUG_OVERLAY
struct DebugOverlayView: View {
    @ObservedObject var viewModel: GameViewModel
    var onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            Divider()
            telemetry
            Divider()
            manualControls
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Debug Overlay")
                    .font(.headline)
                Text("Dev-only — hidden in Release")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
    }

    private var telemetry: some View {
        let debug = viewModel.debugOverlayState

        return VStack(alignment: .leading, spacing: 4) {
            Text("Detector: \(debug.detectorActive ? "On" : "Off")")
                .font(.caption)
            Text("Command: \(debug.activeCommand?.displayName ?? "None")")
                .font(.caption)
            if let last = debug.lastDetectedGesture {
                Text("Last detection: \(last.displayName)")
                    .font(.caption)
            } else {
                Text("Last detection: —")
                    .font(.caption)
            }

            if let acc = debug.acceleration {
                Text(String(format: "Accel x: %.2f  y: %.2f  z: %.2f", acc.x, acc.y, acc.z))
                    .font(.caption2.monospacedDigit())
            }
            if let rot = debug.rotationRate {
                Text(String(format: "Gyro  x: %.2f  y: %.2f  z: %.2f", rot.x, rot.y, rot.z))
                    .font(.caption2.monospacedDigit())
            }

            Text(String(format: "Crown Δ: %.2f", debug.crownAccumulatedDelta))
                .font(.caption2.monospacedDigit())
        }
    }

    private var manualControls: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Manual triggers")
                .font(.caption)
                .foregroundColor(.secondary)

            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    debugButton(for: .shake)
                    debugButton(for: .flickUp)
                }
                HStack(spacing: 6) {
                    debugButton(for: .twist)
                    debugButton(for: .spinCrown)
                }
            }
        }
    }

    private func debugButton(for gesture: GestureType) -> some View {
        Button {
            viewModel.handleGesture(gesture)
        } label: {
            VStack(spacing: 4) {
                debugIcon(for: gesture)
                    .font(.caption)
                Text(gesture.displayName.replacingOccurrences(of: " it!", with: ""))
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(8)
        }
        .buttonStyle(.bordered)
        .tint(viewModel.currentCommand == gesture ? .green : .gray)
    }

    private func debugIcon(for gesture: GestureType) -> some View {
        switch gesture {
        case .shake:
            return Image(systemName: "iphone.radiowaves.left.and.right")
        case .flickUp:
            return Image(systemName: "arrow.up")
        case .twist:
            return Image(systemName: "arrow.clockwise")
        case .spinCrown:
            return Image(systemName: "digitalcrown.horizontal.press")
        }
    }
}
#endif
