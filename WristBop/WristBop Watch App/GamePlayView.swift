//
//  GamePlayView.swift
//  WristBop Watch App
//
//  Created by Stewart Chan on 2025-12-05.
//

import SwiftUI
import WristBopCore

struct GamePlayView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            PerimeterProgressRing(
                progress: perimeterProgress,
                ringColor: timerRingColor
            )

            // Content in center
            VStack(spacing: 12) {
                // Current command display
                if let command = viewModel.currentCommand {
                    Text(command.displayName)
                        .font(.title3)
                        .bold()
                        .foregroundColor(viewModel.didSpeedUp ? .orange : .primary)
                        .animation(.easeInOut, value: viewModel.didSpeedUp)
                }

                // Score
                Text("Score: \(viewModel.score)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Time remaining
                Text(String(format: "%.1fs", viewModel.timeRemaining))
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Spacer()

                // Gesture buttons (2x2 grid)
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        gestureButton(for: .shake)
                        gestureButton(for: .flickUp)
                    }
                    HStack(spacing: 8) {
                        gestureButton(for: .twist)
                        gestureButton(for: .spinCrown)
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Progress & Helper Views

    private var perimeterProgress: Double {
        guard viewModel.maxTimeForCurrentCommand > 0 else { return 0 }
        return viewModel.timeRemaining / viewModel.maxTimeForCurrentCommand
    }

    private var timerRingColor: Color {
        viewModel.timeRemaining < 0.5 ? .red : .blue
    }

    private func gestureButton(for gesture: GestureType) -> some View {
        Button(action: {
            viewModel.handleGesture(gesture)
        }) {
            VStack {
                gestureIcon(for: gesture)
                    .font(.title3)
                Text(gestureName(for: gesture))
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
        }
        .buttonStyle(.bordered)
        .tint(viewModel.currentCommand == gesture ? .green : .gray)
    }

    private func gestureIcon(for gesture: GestureType) -> some View {
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

    private func gestureName(for gesture: GestureType) -> String {
        switch gesture {
        case .shake:
            return "Shake"
        case .flickUp:
            return "Flick"
        case .twist:
            return "Twist"
        case .spinCrown:
            return "Spin"
        }
    }
}

#Preview {
    GamePlayView(viewModel: {
        let vm = GameViewModel(skipCountdown: true)
        vm.startGame()
        return vm
    }())
}
