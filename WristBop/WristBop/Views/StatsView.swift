//
//  StatsView.swift
//  WristBop
//
//  Created by Claude on 2025-12-08.
//

import SwiftUI
import WristBopCore

/// Placeholder view for future stats and leaderboards feature
/// Will display personal stats, achievements, and Game Center leaderboards
struct StatsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.largePadding) {
                // Coming Soon Header
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Theme.primaryGradient)

                    Text("Coming Soon")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Track your progress and compete globally")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Theme.largePadding)

                // Stats Preview Section
                VStack(spacing: Theme.standardPadding) {
                    Text("Personal Stats")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    StatCard(
                        icon: "gamecontroller.fill",
                        title: "Games Played",
                        value: "-",
                        color: Theme.primaryColor
                    )

                    StatCard(
                        icon: "flame.fill",
                        title: "Current Streak",
                        value: "-",
                        color: .orange
                    )

                    StatCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Average Score",
                        value: "-",
                        color: Theme.accentColor
                    )

                    StatCard(
                        icon: "clock.fill",
                        title: "Total Play Time",
                        value: "-",
                        color: .purple
                    )
                }

                // Leaderboards Preview Section
                VStack(spacing: Theme.standardPadding) {
                    HStack {
                        Text("Leaderboards")
                            .font(.headline)

                        Spacer()

                        Image(systemName: "gamecontroller.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Game Center")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    LeaderboardRow(rank: "1", name: "---", score: "-")
                    LeaderboardRow(rank: "2", name: "---", score: "-")
                    LeaderboardRow(rank: "3", name: "---", score: "-")
                }

                Spacer()
            }
            .padding(Theme.standardPadding)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Stats & Leaderboards")
        .navigationBarTitleDisplayMode(.large)
    }
}

/// Preview card for a stat
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: Theme.standardPadding) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(color.opacity(0.1))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }

            Spacer()
        }
        .padding(Theme.standardPadding)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Color(uiColor: .systemBackground))
        )
        .opacity(0.6) // Disabled appearance for "coming soon"
    }
}

/// Preview row for leaderboard entry
struct LeaderboardRow: View {
    let rank: String
    let name: String
    let score: String

    var body: some View {
        HStack(spacing: Theme.standardPadding) {
            Text(rank)
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(width: 30)

            Text(name)
                .font(.body)

            Spacer()

            Text(score)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(Theme.primaryColor)
        }
        .padding(Theme.standardPadding)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Color(uiColor: .systemBackground))
        )
        .opacity(0.6) // Disabled appearance for "coming soon"
    }
}

#Preview {
    NavigationStack {
        StatsView()
    }
}
