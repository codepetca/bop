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
        ZStack(alignment: .topTrailing) {
            // Main content - centered Play button with title
            VStack {
                Spacer()

                // Large green Play button with "WristBop" title
                Button(action: {
                    viewModel.startGame()
                }) {
                    VStack(spacing: 8) {
                        Text("WristBop")
                            .font(.title2)
                            .bold()
                            .modifier(JiggleEffect())

                        Image(systemName: "play.fill")
                            .font(.system(size: 32))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.green)
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)

                Spacer()
            }

            // High score in top-right
            HStack(spacing: 4) {
                Image(systemName: "crown.fill")
                    .font(.caption)
                Text("\(viewModel.highScore)")
                    .font(.caption)
            }
            .foregroundColor(.yellow)
            .padding(8)
        }
    }
}

#Preview {
    MainMenuView(viewModel: GameViewModel(skipCountdown: true))
}
