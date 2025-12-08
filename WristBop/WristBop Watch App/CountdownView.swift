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
            PerimeterProgressRing(
                progress: viewModel.countdownTimeRemaining / 3.0,
                ringColor: .blue
            )

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
