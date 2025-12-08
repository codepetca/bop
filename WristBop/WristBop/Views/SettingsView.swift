//
//  SettingsView.swift
//  WristBop
//
//  Created by Claude on 2025-12-08.
//

import SwiftUI
import WristBopCore

/// Placeholder view for future settings and customization
/// Will allow users to configure difficulty, haptics, sounds, and more
struct SettingsView: View {
    var body: some View {
        Form {
            Section {
                VStack(alignment: .center, spacing: 12) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)

                    Text("Settings Coming Soon")
                        .font(.headline)

                    Text("Customize your WristBop experience")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.standardPadding)
            }

            Section("Game Settings") {
                SettingsRow(icon: "speedometer", title: "Difficulty Mode", value: "Auto")
                SettingsRow(icon: "timer", title: "Starting Speed", value: "Normal")
                SettingsRow(icon: "waveform", title: "Haptic Feedback", value: "On")
            }

            Section("Audio") {
                SettingsRow(icon: "speaker.wave.2", title: "Sound Effects", value: "On")
                SettingsRow(icon: "music.note", title: "Background Music", value: "Off")
                SettingsRow(icon: "slider.horizontal.3", title: "Volume", value: "80%")
            }

            Section("Accessibility") {
                SettingsRow(icon: "eye", title: "Reduced Motion", value: "Off")
                SettingsRow(icon: "textformat.size", title: "Text Size", value: "Medium")
                SettingsRow(icon: "accessibility", title: "Voice Guidance", value: "Off")
            }

            Section("Data") {
                SettingsRow(icon: "arrow.clockwise", title: "Sync with iCloud", value: "Off")
                SettingsRow(icon: "trash", title: "Reset High Score", value: "", isDestructive: true)
            }

            Section {
                Text("Game version 1.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}

/// Preview row for a settings option
struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String
    var isDestructive: Bool = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isDestructive ? .red : Theme.primaryColor)
                .frame(width: 24)

            Text(title)
                .foregroundColor(isDestructive ? .red : .primary)

            Spacer()

            if !value.isEmpty {
                Text(value)
                    .foregroundColor(.secondary)
            }
        }
        .opacity(0.6) // Disabled appearance for "coming soon"
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
