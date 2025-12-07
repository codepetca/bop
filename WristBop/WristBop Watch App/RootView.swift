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

    var body: some View {
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
}

#Preview {
    RootView()
}
