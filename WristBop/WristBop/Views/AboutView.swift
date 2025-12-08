//
//  AboutView.swift
//  WristBop
//
//  Created by Claude on 2025-12-08.
//

import SwiftUI
import WristBopCore

/// About screen with app information and game instructions
struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.largePadding) {
                // App Icon and Name
                VStack(spacing: 12) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(Theme.primaryGradient)

                    Text("WristBop")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Version 1.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, Theme.largePadding)

                // Description
                VStack(alignment: .leading, spacing: Theme.standardPadding) {
                    Text("About")
                        .font(.headline)

                    Text("WristBop is a fast-reaction game for Apple Watch inspired by the classic \"Bop It\" toy. Test your reflexes by responding to on-screen gesture commands before time runs out!")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(Theme.standardPadding)
                .background(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .fill(Color(uiColor: .systemBackground))
                )

                // How to Play
                VStack(alignment: .leading, spacing: Theme.standardPadding) {
                    Text("How to Play")
                        .font(.headline)

                    GestureInstruction(
                        gesture: .shake,
                        description: "Shake your wrist rapidly"
                    )

                    GestureInstruction(
                        gesture: .flickUp,
                        description: "Flick your wrist upward"
                    )

                    GestureInstruction(
                        gesture: .twist,
                        description: "Twist your wrist left or right"
                    )

                    GestureInstruction(
                        gesture: .spinCrown,
                        description: "Spin the Digital Crown"
                    )

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(icon: "clock.fill", text: "Each gesture must be completed within the time limit")
                        InfoRow(icon: "speedometer", text: "Game speeds up every 3 successful gestures")
                        InfoRow(icon: "target", text: "Only timeouts end the game - wrong gestures are ignored")
                    }
                }
                .padding(Theme.standardPadding)
                .background(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .fill(Color(uiColor: .systemBackground))
                )

                // Game Constants
                VStack(alignment: .leading, spacing: Theme.standardPadding) {
                    Text("Game Info")
                        .font(.headline)

                    HStack {
                        Text("Starting Time:")
                        Spacer()
                        Text("\(String(format: "%.1f", GameConstants.initialTimePerCommand))s")
                            .foregroundColor(Theme.primaryColor)
                            .fontWeight(.semibold)
                    }

                    HStack {
                        Text("Minimum Time:")
                        Spacer()
                        Text("\(String(format: "%.1f", GameConstants.minimumTimePerCommand))s")
                            .foregroundColor(Theme.primaryColor)
                            .fontWeight(.semibold)
                    }

                    HStack {
                        Text("Speed Increase:")
                        Spacer()
                        Text("Every \(GameConstants.successesPerDifficultyRamp) successes")
                            .foregroundColor(Theme.primaryColor)
                            .fontWeight(.semibold)
                    }

                    HStack {
                        Text("Time Decrease:")
                        Spacer()
                        Text("-\(String(format: "%.1f", GameConstants.timeDecrementPerRamp))s")
                            .foregroundColor(Theme.primaryColor)
                            .fontWeight(.semibold)
                    }
                }
                .padding(Theme.standardPadding)
                .background(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .fill(Color(uiColor: .systemBackground))
                )

                // Footer
                VStack(spacing: 8) {
                    Text("© 2025 CodePet")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("Built with Swift & SwiftUI")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, Theme.largePadding)

                Spacer()
            }
            .padding(Theme.standardPadding)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.large)
    }
}

/// Gesture instruction row
struct GestureInstruction: View {
    let gesture: GestureType
    let description: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Circle()
                .fill(Theme.primaryColor.opacity(0.1))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(gesture.displayName)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.primaryColor)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

/// Info row with icon
struct InfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(Theme.accentColor)
                .frame(width: 16)

            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
