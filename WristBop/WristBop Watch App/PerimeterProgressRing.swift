//
//  PerimeterProgressRing.swift
//  WristBop Watch App
//
//  Created by Stewart Chan on 2025-12-07.
//

import SwiftUI

struct PerimeterProgressRing: View {
    var progress: Double
    var ringColor: Color
    var trackColor: Color = Color.gray.opacity(0.2)
    var animationDuration: Double = 0.05
    var ringWidthScale: CGFloat = 0.05
    var cornerRadiusScale: CGFloat = 0.24
    var showTrack: Bool = true

    var body: some View {
        GeometryReader { geometry in
            let minSide = min(geometry.size.width, geometry.size.height)
            let ringWidth = minSide * ringWidthScale
            let cornerRadius = minSide * cornerRadiusScale
            let clampedProgress = CGFloat(max(0, min(progress, 1)))

            ZStack {
                if showTrack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .trim(from: 0, to: 1)
                        .stroke(trackColor, style: StrokeStyle(lineWidth: ringWidth))
                }

                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .trim(from: 0, to: clampedProgress)
                    .stroke(
                        ringColor,
                        style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                    )
                    .animation(.linear(duration: animationDuration), value: clampedProgress)
            }
            .rotationEffect(.degrees(-90))
            .padding(ringWidth / 2)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    PerimeterProgressRing(
        progress: 0.65,
        ringColor: .blue
    )
}
