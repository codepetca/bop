//
//  GameOverView.swift
//  WristBop Watch App
//
//  Created by Stewart Chan on 2025-12-05.
//

import SwiftUI
import WristBopCore

struct GameOverView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            Color.red.opacity(0.2)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Game Over!")
                    .font(.title2)
                    .bold()

                VStack(spacing: 8) {
                    Text("Score: \(viewModel.score)")
                        .font(.title)
                        .bold()

                    if viewModel.score >= viewModel.highScore && viewModel.score > 0 {
                        Text("New High Score! 🎉")
                            .font(.caption)
                            .foregroundColor(.orange)
                    } else {
                        Text("High Score: \(viewModel.highScore)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if viewModel.canTapToSkipGameOver {
                viewModel.returnToMenu()
            }
        }
    }
}

#Preview {
    GameOverView(viewModel: {
        let vm = GameViewModel(skipCountdown: true)
        vm.startGame()
        return vm
    }())
}
