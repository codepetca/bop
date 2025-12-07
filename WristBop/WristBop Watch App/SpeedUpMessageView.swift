//
//  SpeedUpMessageView.swift
//  WristBop Watch App
//
//  Created by Stewart Chan on 2025-12-05.
//

import SwiftUI
import WristBopCore

struct SpeedUpMessageView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            Color.orange.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("SPEED UP!")
                    .font(.title)
                    .bold()
                    .foregroundColor(.orange)

                Text("Score: \(viewModel.score)")
                    .font(.title3)

                Text("Get ready...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    SpeedUpMessageView(viewModel: GameViewModel(skipCountdown: true))
}
