//
//  TimeChallengeView_StartView.swift
//  PlayNewNew
//
//  Created by Chengzhi 张 on 2024/10/19.
//

import SwiftUI

struct TimeChallengeView_StartView: View {
    @State private var countdownFinished = false

    var body: some View {
        if countdownFinished {
            TimeChallengeView_ChallengeScreen()
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

private struct TimeChallengeView_ChallengeScreen: View {
    @StateObject private var viewModel = TimeChallengeSessionViewModel()

    var body: some View {
        ZStack {
            Text("⏰")
                .font(.system(size: 150))
                .opacity(0.2)
                .blur(radius: 4)

            if viewModel.isShaking {
                VStack {
                    Spacer()

                    Text("⏰时长挑战开始")
                        .font(.custom("zixiaohunnaitangti_T", size: 18))

                    Text(viewModel.formattedTime())
                        .font(.custom("zixiaohunnaitangti_T", size: 28))
                        .tracking(3)
                        .bold()
                        .padding(.top)

                    Spacer()

                    Button(action: { viewModel.stopChallenge() }) {
                        Text("结束挑战")
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom, 1)

                    Text("🍼已挤奶\(viewModel.shakeCount)下")
                        .font(.custom("zixiaohunnaitangti_T", size: 13))
                        .padding(.bottom, 5)
                }
            } else {
                VStack {
                    Text("时长挑战结束")
                        .font(.custom("zixiaohunnaitangti_T", size: 20))
                        .padding(.bottom, 20)

                    Text("⏱挑战用时：\(viewModel.formattedTime())")
                        .font(.custom("zixiaohunnaitangti_T", size: 13))
                        .padding(.bottom, 5)
                    Text("👋摇晃次数：\(viewModel.shakeCount)")
                        .font(.custom("zixiaohunnaitangti_T", size: 13))
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

#Preview {
    TimeChallengeView_ChallengeScreen()
}
