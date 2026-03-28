//
//  FrequencyChallengeView_StartView.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/9/9.
//

import SwiftUI

struct FrequencyChallengeView_StartView: View {
    @Binding var vibratefrequency: Int
    @State private var countdownFinished = false

    var body: some View {
        if countdownFinished {
            FrequencyChallengeView_ChallengeScreen(vibratefrequency: $vibratefrequency)
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

private struct FrequencyChallengeView_ChallengeScreen: View {
    @Binding var vibratefrequency: Int
    @StateObject private var viewModel = FrequencyChallengeSessionViewModel()

    var body: some View {
        ZStack {
            Text("👌")
                .font(.system(size: 150))
                .opacity(0.2)
                .blur(radius: 4)
            if viewModel.isShaking {
                VStack {
                    Spacer()

                    Text("👌频率挑战开始")
                        .font(.custom("zixiaohunnaitangti_T", size: 18))

                    Text(viewModel.formattedTime())
                        .font(.custom("zixiaohunnaitangti_T", size: 28))
                        .tracking(3)
                        .bold()
                        .padding(.top)

                    Spacer()

                    Text("🍼已挤奶\(viewModel.shakeCount)下")
                        .font(.custom("zixiaohunnaitangti_T", size: 13))
                        .padding(.bottom, 5)

                    Text("停止挤奶三秒后自动结束挑战")
                        .font(.custom("zixiaohunnaitangti_T", size: 10))
                        .opacity(0.7)
                        .padding(.bottom, 10)
                }
            } else {
                VStack {
                    Text("频率挑战结束")
                        .font(.custom("zixiaohunnaitangti_T", size: 20))
                        .padding(.bottom, 20)

                    Text("👋目标频率：\(vibratefrequency)下/秒")
                        .font(.custom("zixiaohunnaitangti_T", size: 13))
                        .padding(.bottom, 5)
                    Text("⏱实际用时：\(viewModel.formattedTimeMinusThree())")
                        .font(.custom("zixiaohunnaitangti_T", size: 13))
                        .padding(.bottom, 5)
                    Text("👋摇晃次数：\(viewModel.shakeCount)")
                        .font(.custom("zixiaohunnaitangti_T", size: 13))
                }
            }
        }
        .onAppear {
            viewModel.vibrateFrequency = vibratefrequency
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }
}
