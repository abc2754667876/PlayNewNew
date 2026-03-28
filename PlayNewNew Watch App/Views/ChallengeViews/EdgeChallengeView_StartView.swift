//
//  EdgeChallengeView_StartView.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/9/17.
//

import SwiftUI

struct EdgeChallengeView_StartView: View {
    @State private var countdownFinished = false

    var body: some View {
        if countdownFinished {
            EdgeChallengeView_ChallengeScreen()
        } else {
            ChallengeCountdownContainer(countdownFinished: $countdownFinished)
        }
    }
}

private struct ChallengeCountdownContainer: View {
    @StateObject private var viewModel = ChallengeCountdownViewModel()
    @Binding var countdownFinished: Bool
    @State private var didStart = false

    var body: some View {
        ZStack {
            if let n = viewModel.displayedNumber {
                Text(n)
                    .font(.custom("zixiaohunnaitangti_T", size: 100))
                    .scaleEffect(viewModel.isAnimating ? 1.0 : 0.1)
                    .opacity(viewModel.isAnimating ? 1.0 : 0.0)
                    .blur(radius: viewModel.isAnimating ? 0.0 : 15.0)
                    .animation(.easeInOut(duration: 0.5), value: viewModel.isAnimating)
            }
        }
        .onAppear {
            guard !didStart else { return }
            didStart = true
            viewModel.start(countdownFinished: $countdownFinished)
        }
    }
}

private struct EdgeChallengeView_ChallengeScreen: View {
    @StateObject private var viewModel = EdgeChallengeSessionViewModel()

    var body: some View {
        ZStack {
            Text("🤞")
                .font(.system(size: 150))
                .opacity(0.2)
                .blur(radius: 4)

            if viewModel.milkingCompleted {
                VStack {
                    Text("🤞边缘挑战完成")
                        .font(.custom("zixiaohunnaitangti_T", size: 20))
                    Text("本次坚持了\(viewModel.completedRoundsText)轮")
                        .font(.custom("zixiaohunnaitangti_T", size: 14))
                        .padding(.top)
                        .opacity(0.8)
                }
            } else {
                VStack {
                    Text("🤞边缘挑战开始-第\(viewModel.rounds)轮")
                        .font(.custom("zixiaohunnaitangti_T", size: 12))
                        .padding(.top, 30)
                        .padding(.bottom, 5)
                        .opacity(0.8)

                    Text(viewModel.statusText)
                        .font(.custom("zixiaohunnaitangti_T", size: 18))

                    Spacer()

                    Text("\(viewModel.countdown)")
                        .font(.custom("zixiaohunnaitangti_T", size: 48))

                    Spacer()

                    Text("👋已挤奶\(viewModel.shakeCount)下")
                        .font(.custom("zixiaohunnaitangti_T", size: 13))
                        .opacity(0.9)
                        .padding(.bottom)
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

#Preview {
    EdgeChallengeView_ChallengeScreen()
}
