//
//  CountdownView.swift
//  WristBop Watch App
//
//  Created by Stewart Chan on 2025-12-05.
//

import SwiftUI
import WristBopCore

struct CountdownView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            // Full-screen circular timer at edge
            GeometryReader { geometry in
                ZStack {
                    // Background circle at edge
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                        .frame(width: geometry.size.width - 10, height: geometry.size.height - 10)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                    // Animated countdown ring at edge
                    Circle()
                        .trim(from: 0, to: viewModel.countdownTimeRemaining / 3.0)
                        .stroke(
                            Color.blue,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: geometry.size.width - 10, height: geometry.size.height - 10)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.05), value: viewModel.countdownTimeRemaining)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
            .ignoresSafeArea()

            // Center text
            VStack {
                if viewModel.showingGo {
                    Text("GO!")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.green)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Text("Ready")
                        .font(.largeTitle)
                        .bold()
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
}

#Preview {
    CountdownView(viewModel: {
        let vm = GameViewModel(skipCountdown: false)
        vm.startGame()
        return vm
    }())
}
