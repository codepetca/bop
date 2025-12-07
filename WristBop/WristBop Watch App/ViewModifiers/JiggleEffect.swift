//
//  JiggleEffect.swift
//  WristBop Watch App
//
//  Created by Stewart Chan on 2025-12-05.
//

import SwiftUI

struct JiggleEffect: ViewModifier {
    @State private var isJiggling = false

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isJiggling ? 5 : 0))
            .onAppear {
                startJiggleTimer()
            }
    }

    private func startJiggleTimer() {
        // Jiggle immediately on appear
        performJiggle()

        // Then repeat every 5 seconds
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            performJiggle()
        }
    }

    private func performJiggle() {
        // Quick back-and-forth jiggle animation
        withAnimation(.easeInOut(duration: 0.1)) {
            isJiggling = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                isJiggling = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isJiggling = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isJiggling = false
                    }
                }
            }
        }
    }
}
