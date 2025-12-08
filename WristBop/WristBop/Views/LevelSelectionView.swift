//
//  LevelSelectionView.swift
//  WristBop
//
//  Created by Claude on 2025-12-08.
//

import SwiftUI
import WristBopCore

/// Placeholder view for future level selection feature
/// Will allow users to choose difficulty modes and custom challenges
struct LevelSelectionView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.largePadding) {
                // Coming Soon Header
                VStack(spacing: 12) {
                    Image(systemName: "target")
                        .font(.system(size: 60))
                        .foregroundStyle(Theme.primaryGradient)

                    Text("Coming Soon")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Level selection and difficulty modes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Theme.largePadding)

                // Preview Cards
                VStack(spacing: Theme.standardPadding) {
                    LevelCard(
                        title: "Classic Mode",
                        description: "Standard endless gameplay",
                        icon: "infinity",
                        color: Theme.primaryColor
                    )

                    LevelCard(
                        title: "Time Trial",
                        description: "Beat the clock",
                        icon: "clock.fill",
                        color: .orange
                    )

                    LevelCard(
                        title: "Perfect Run",
                        description: "No mistakes allowed",
                        icon: "star.fill",
                        color: Theme.accentColor
                    )

                    LevelCard(
                        title: "Custom",
                        description: "Create your own challenge",
                        icon: "slider.horizontal.3",
                        color: .purple
                    )
                }

                Spacer()
            }
            .padding(Theme.standardPadding)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Level Selection")
        .navigationBarTitleDisplayMode(.large)
    }
}

/// Preview card for a level/mode
struct LevelCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: Theme.standardPadding) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(color.opacity(0.1))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(Theme.standardPadding)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Color(uiColor: .systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .opacity(0.6) // Disabled appearance for "coming soon"
    }
}

#Preview {
    NavigationStack {
        LevelSelectionView()
    }
}
