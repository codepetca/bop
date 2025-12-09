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
            statusRow
            telemetry
            manualControls
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var header: some View {
        HStack(spacing: 8) {
            Label("Debug", systemImage: "ladybug.fill")
                .font(.headline)
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
    }

    private var statusRow: some View {
        let debug = viewModel.debugOverlayState

        return HStack(spacing: 6) {
            statusChip(
                icon: Image(systemName: debug.detectorActive ? "dot.radiowaves.right" : "wave.3.right"),
                label: "Detector",
                tint: debug.detectorActive ? .green : .red
            )
        }
    }

    private func statusChip(icon: Image, label: String, tint: Color) -> some View {
        HStack(spacing: 4) {
            icon
                .font(.caption)
            Text(label)
                .font(.caption2)
                .lineLimit(1)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 5)
        .background(tint.opacity(0.15))
        .foregroundStyle(tint)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var telemetry: some View {
        let debug = viewModel.debugOverlayState

        return HStack(spacing: 6) {
            telemetryGroup(
                label: "A",
                values: debug.acceleration.map { ($0.x, $0.y, $0.z) }
            )
            telemetryGroup(
                label: "G",
                values: debug.rotationRate.map { ($0.x, $0.y, $0.z) }
            )
            telemetryGroup(
                label: "Cr",
                values: (debug.crownAccumulatedDelta, nil, nil)
            )
        }
    }

    private func telemetryGroup(label: String, values: (Double, Double?, Double?)?) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption2.weight(.semibold))
            if let values {
                Text(compactValues(values))
                    .font(.caption2.monospacedDigit())
            } else {
                Text("—")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func compactValues(_ values: (Double, Double?, Double?)) -> String {
        switch values {
        case let (first, nil, nil):
            return String(format: "%.2f", first)
        case let (x, y?, z?):
            return String(format: "%.1f %.1f %.1f", x, y, z)
        default:
            return "—"
        }
    }

    private var manualControls: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 2)
        let lastDetected = viewModel.debugOverlayState.lastDetectedGesture

        return LazyVGrid(columns: columns, spacing: 6) {
            debugButton(for: .shake, lastDetected: lastDetected)
            debugButton(for: .flickUp, lastDetected: lastDetected)
            debugButton(for: .twist, lastDetected: lastDetected)
            debugButton(for: .spinCrown, lastDetected: lastDetected)
        }
    }

    private func debugButton(for gesture: GestureType, lastDetected: GestureType?) -> some View {
        Button {
            viewModel.handleGesture(gesture)
        } label: {
            Text(shortName(for: gesture))
                .font(.footnote)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.bordered)
        .tint(viewModel.currentCommand == gesture ? .green : .gray)
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(lastDetected == gesture ? Color.blue : .clear, lineWidth: 2)
        )
    }

    private func debugIcon(for gesture: GestureType, monochrome: Bool = false) -> Image {
        switch gesture {
        case .shake:
            return Image(systemName: monochrome ? "iphone.radiowaves.left.and.right" : "iphone.radiowaves.left.and.right.circle")
        case .flickUp:
            return Image(systemName: monochrome ? "arrow.up" : "arrow.up.circle")
        case .twist:
            return Image(systemName: monochrome ? "arrow.clockwise" : "arrow.clockwise.circle")
        case .spinCrown:
            return Image(systemName: "digitalcrown.horizontal.press")
        }
    }

    private func shortName(for gesture: GestureType) -> String {
        switch gesture {
        case .shake:
            return "Shake"
        case .flickUp:
            return "Flick"
        case .twist:
            return "Twist"
        case .spinCrown:
            return "Crown"
        }
    }
}
#endif
