//
//  Theme.swift
//  WristBop
//
//  Created by Claude on 2025-12-08.
//

import SwiftUI

/// Centralized theme configuration for WristBop
/// Makes it easy to customize colors and switch themes in the future
enum Theme {
    // MARK: - Colors

    /// Primary brand color - Electric Purple/Indigo
    /// Used for main UI elements, buttons, and highlights
    static let primaryColor = Color(hex: "6366F1")

    /// Accent color - Bright Cyan
    /// Used for success states, highlights, and interactive elements
    static let accentColor = Color(hex: "22D3EE")

    /// Gradient background for cards and featured elements
    static let primaryGradient = LinearGradient(
        colors: [primaryColor.opacity(0.8), primaryColor],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Typography

    /// Large title font size for headers
    static let largeTitleSize: CGFloat = 34

    /// Standard title font size
    static let titleSize: CGFloat = 28

    /// Body text font size
    static let bodySize: CGFloat = 17

    // MARK: - Spacing

    /// Standard padding for views
    static let standardPadding: CGFloat = 16

    /// Large padding for sections
    static let largePadding: CGFloat = 24

    /// Corner radius for cards and buttons
    static let cornerRadius: CGFloat = 16
}

// MARK: - Color Extension for Hex Support

extension Color {
    /// Initialize Color from hex string
    /// - Parameter hex: Hex color string (e.g., "6366F1" or "#6366F1")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}
