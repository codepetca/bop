//
//  ContentView.swift
//  WristBop Watch App
//
//  Created by Stewart Chan on 2025-12-05.
//

import SwiftUI
import WristBopCore

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        if viewModel.isGameOver {
            // Game over screen (check this FIRST!)
            gameOverView
        } else if !viewModel.isPlaying {
            // Main menu
            mainMenuView
        } else if viewModel.showingSpeedUpMessage {
            // Speed up message
            speedUpView
        } else {
            // Game play screen
            gamePlayView
        }
    }

    // MARK: - Main Menu

    private var mainMenuView: some View {
        VStack(spacing: 20) {
            Text("WristBop")
                .font(.title2)
                .bold()

            Text("High Score: \(viewModel.highScore)")
                .font(.caption)
                .foregroundColor(.secondary)

            Button(action: {
                viewModel.startGame()
            }) {
                Text("Start Game")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // MARK: - Game Play

    private var gamePlayView: some View {
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

            // Timer progress bar
            ProgressView(value: viewModel.timeRemaining, total: viewModel.maxTimeForCurrentCommand)
                .progressViewStyle(.linear)
                .tint(viewModel.timeRemaining < 0.5 ? .red : .blue)

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

    // MARK: - Speed Up Message

    private var speedUpView: some View {
        ZStack {
            Color.orange.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("SPEED UP!")
                    .font(.title)
                    .bold()
                    .foregroundColor(.orange)

                Text("Score: \(viewModel.score)")
                    .font(.title3)

                Text("Get ready...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Game Over

    private var gameOverView: some View {
        ZStack {
            Color.red.opacity(0.2)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Game Over!")
                    .font(.title2)
                    .bold()

                VStack(spacing: 8) {
                    Text("Score: \(viewModel.score)")
                        .font(.title)
                        .bold()

                    if viewModel.score >= viewModel.highScore && viewModel.score > 0 {
                        Text("New High Score! 🎉")
                            .font(.caption)
                            .foregroundColor(.orange)
                    } else {
                        Text("High Score: \(viewModel.highScore)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if viewModel.canTapToSkipGameOver {
                viewModel.returnToMenu()
            }
        }
    }
}

#Preview {
    ContentView()
}
