//
//  RootView.swift
//  WristBop Watch App
//
//  Created by Stewart Chan on 2025-12-05.
//

import SwiftUI
import WristBopCore

struct RootView: View {
    @StateObject private var viewModel = GameViewModel()
#if DEBUG_OVERLAY
    @State private var isShowingDebugOverlay = false
#endif

    var body: some View {
        ZStack(alignment: .topTrailing) {
            mainContent
#if DEBUG_OVERLAY
            debugOverlayToggle
                .padding()

            if isShowingDebugOverlay {
                DebugOverlayView(viewModel: viewModel) {
                    withAnimation {
                        isShowingDebugOverlay = false
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding()
            }
#endif
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if viewModel.showingCountdown {
            // Countdown screen (check this FIRST!)
            CountdownView(viewModel: viewModel)
        } else if viewModel.isGameOver {
            // Game over screen
            GameOverView(viewModel: viewModel)
        } else if !viewModel.isPlaying {
            // Main menu
            MainMenuView(viewModel: viewModel)
        } else if viewModel.showingSpeedUpMessage {
            // Speed up message
            SpeedUpMessageView(viewModel: viewModel)
        } else {
            // Game play screen
            GamePlayView(viewModel: viewModel)
        }
    }

#if DEBUG_OVERLAY
    private var debugOverlayToggle: some View {
        Button {
            withAnimation {
                isShowingDebugOverlay.toggle()
            }
        } label: {
            Image(systemName: isShowingDebugOverlay ? "eye.slash" : "ladybug")
                .font(.body.weight(.bold))
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
#endif
}

#Preview {
    RootView()
}
