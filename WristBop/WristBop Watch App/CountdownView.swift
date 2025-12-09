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
            if let value = viewModel.countdownValue {
                Text("\(value)")
                    .font(.system(size: 88, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.4)
                    .id(value)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CountdownView(viewModel: {
        let vm = GameViewModel(skipCountdown: false)
        vm.startGame()
        return vm
    }())
}
