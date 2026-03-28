//
//  FrequencyChallengeView.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/9/9.
//

import SwiftUI

struct FrequencyChallengeView: View {
    @StateObject private var viewModel = FrequencyChallengeViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Text("👌")
                    .font(.system(size: 150))
                    .opacity(0.2)
                    .blur(radius: 4)

                ScrollView {
                    VStack {
                        Text("👌频率挑战")
                            .font(.custom("zixiaohunnaitangti_T", size: 20))
                            .padding(.top, 30)

                        HStack {
                            Text("选择频率：")
                                .font(.custom("zixiaohunnaitangti_T", size: 13))
                            Spacer()
                        }
                        .padding(.top, 15)

                        Picker("", selection: Binding(
                            get: { viewModel.selectedNumber },
                            set: { viewModel.selectedNumber = $0 }
                        )) {
                            ForEach(viewModel.numbers, id: \.self) { number in
                                Text("\(number)").tag(number)
                                    .font(.custom("zixiaohunnaitangti_T", size: 13))
                            }
                        }
                        .frame(height: 50)
                        .pickerStyle(.wheel)

                        Text("即每秒摇晃手臂\(viewModel.selectedNumber)个来回")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.8)
                            .padding(.top, 3)
                            .padding(.bottom)

                        Button(action: { viewModel.toggleVibration() }) {
                            Text(viewModel.buttonText)
                                .font(.custom("zixiaohunnaitangti_T", size: 14))
                        }

                        NavigationLink(destination: FrequencyChallengeView_StartView(vibratefrequency: Binding(
                            get: { viewModel.selectedNumber },
                            set: { viewModel.selectedNumber = $0 }
                        ))) {
                            Text("进入挑战")
                                .font(.custom("zixiaohunnaitangti_T", size: 14))
                                .foregroundStyle(.red)
                        }
                        .padding(.top, 5)
                        .padding(.bottom)

                        Text("提示：跟随震动摇晃手臂,停止摇晃三秒后自动结束")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .padding(.bottom)
                            .multilineTextAlignment(.center)
                            .opacity(0.8)
                    }
                }
            }
            .onDisappear {
                viewModel.onDisappear()
            }
        }
    }
}

#Preview {
    FrequencyChallengeView()
}
