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
            // Full-screen circular timer at edge
            GeometryReader { geometry in
                ZStack {
                    // Background circle at edge
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                        .frame(width: geometry.size.width - 10, height: geometry.size.height - 10)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                    // Animated timer ring at edge
                    Circle()
                        .trim(from: 0, to: viewModel.timeRemaining / viewModel.maxTimeForCurrentCommand)
                        .stroke(
                            viewModel.timeRemaining < 0.5 ? Color.red : Color.blue,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: geometry.size.width - 10, height: geometry.size.height - 10)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.05), value: viewModel.timeRemaining)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
            .ignoresSafeArea()

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
            }
            .padding()
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
