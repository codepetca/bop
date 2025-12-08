//
//  HomeView.swift
//  WristBop
//
//  Created by Claude on 2025-12-08.
//

import SwiftUI
import WristBopCore

/// Main home screen for the iOS companion app
/// Displays high score and navigation to future features
struct HomeView: View {
    @State private var highScore: Int = 0

    private let highScoreStore = UserDefaultsHighScoreStore()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.largePadding) {
                    // App Title and Icon
                    VStack(spacing: 12) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Theme.primaryGradient)

                        Text("WristBop")
                            .font(.system(size: Theme.largeTitleSize, weight: .bold))
                            .foregroundColor(Theme.primaryColor)

                        Text("Fast-Reaction Game for Apple Watch")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, Theme.largePadding)

                    // High Score Card
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(Theme.accentColor)
                            Text("High Score")
                                .font(.headline)
                            Spacer()
                        }

                        Text("\(highScore)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(Theme.primaryGradient)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 8)

                        Text(highScore > 0 ? "Keep it up!" : "Play on your Apple Watch to set a score")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(Theme.standardPadding)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                            .fill(Color(uiColor: .systemBackground))
                            .shadow(color: Theme.primaryColor.opacity(0.1), radius: 10, x: 0, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                            .stroke(Theme.primaryColor.opacity(0.2), lineWidth: 1)
                    )

                    // Features Navigation
                    VStack(spacing: Theme.standardPadding) {
                        Text("Features")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)

                        NavigationLink {
                            LevelSelectionView()
                        } label: {
                            FeatureRow(
                                icon: "target",
                                title: "Level Selection",
                                subtitle: "Choose your challenge",
                                color: Theme.primaryColor
                            )
                        }

                        NavigationLink {
                            SettingsView()
                        } label: {
                            FeatureRow(
                                icon: "gearshape.fill",
                                title: "Settings",
                                subtitle: "Customize your experience",
                                color: .orange
                            )
                        }

                        NavigationLink {
                            StatsView()
                        } label: {
                            FeatureRow(
                                icon: "chart.bar.fill",
                                title: "Stats & Leaderboards",
                                subtitle: "Track your progress",
                                color: Theme.accentColor
                            )
                        }

                        NavigationLink {
                            AboutView()
                        } label: {
                            FeatureRow(
                                icon: "info.circle.fill",
                                title: "About",
                                subtitle: "Learn more about WristBop",
                                color: .purple
                            )
                        }
                    }

                    Spacer(minLength: Theme.largePadding)
                }
                .padding(Theme.standardPadding)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            loadHighScore()
        }
    }

    private func loadHighScore() {
        highScore = highScoreStore.loadHighScore()
    }
}

/// Reusable feature row component for navigation items
struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: Theme.standardPadding) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(Theme.standardPadding)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Color(uiColor: .systemBackground))
        )
    }
}

#Preview {
    HomeView()
}
