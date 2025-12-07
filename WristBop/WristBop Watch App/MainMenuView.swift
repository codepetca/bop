//
//  MainMenuView.swift
//  WristBop Watch App
//
//  Created by Stewart Chan on 2025-12-05.
//

import SwiftUI
import WristBopCore

struct MainMenuView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Title with jiggle animation
            Text("WristBop")
                .font(.title2)
                .bold()
                .modifier(JiggleEffect())

            // High score with crown icon
            HStack(spacing: 4) {
                Image(systemName: "crown.fill")
                    .font(.caption)
                Text("\(viewModel.highScore)")
                    .font(.caption)
            }
            .foregroundColor(.secondary)

            // Play button
            Button(action: {
                viewModel.startGame()
            }) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
}

#Preview {
    MainMenuView(viewModel: GameViewModel(skipCountdown: true))
}
