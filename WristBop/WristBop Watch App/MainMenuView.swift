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
        VStack {
            // High score centered at top
            HStack(spacing: 4) {
                Image(systemName: "crown.fill")
                    .font(.caption)
                Text("\(viewModel.highScore)")
                    .font(.caption)
            }
            .foregroundColor(.yellow)
            .padding(.top)

            // Title centered below high score
            Text("WristBop")
                .font(.title2)
                .bold()

            Spacer()

            // Large triangular Play button
            PlayButtonView(onPlay: {
                viewModel.startGame()
            })
            .padding(.horizontal, 16)

            Spacer()
        }
    }
}

struct PlayButtonView: View {
    let onPlay: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height) * 0.9

            Button(action: onPlay) {
                Image(systemName: "play.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .foregroundStyle(.green)
                    .padding()
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(width: geometry.size.width,
                   height: geometry.size.height,
                   alignment: .center)
        }
    }
}

#Preview {
    MainMenuView(viewModel: GameViewModel(skipCountdown: true))
}
