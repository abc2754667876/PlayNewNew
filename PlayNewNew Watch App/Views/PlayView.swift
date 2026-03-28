//
//  PlayView.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/8/12.
//

import SwiftUI

struct PlayView: View {
    @StateObject private var viewModel = PlayViewModel()

    var body: some View {
        ZStack {
            if viewModel.heartRateMeasurementService.currentHeartRate > 20 {
                Text("❤️")
                    .font(.system(size: 150))
                    .opacity(0.2)
                    .blur(radius: 5)
                    .scaleEffect(viewModel.isAnimating ? 1.0 : 0)
                    .animation(
                        Animation.easeInOut(duration: Double(60) / Double(viewModel.heartRateMeasurementService.currentHeartRate) / 2)
                            .repeatForever(autoreverses: true),
                        value: viewModel.isAnimating
                    )
                    .onAppear {
                        viewModel.isAnimating = true
                    }
            } else {
                Text("❤️")
                    .font(.system(size: 150))
                    .opacity(0.2)
                    .blur(radius: 5)
                    .scaleEffect(viewModel.isAnimating ? 1.2 : 0.8)
                    .animation(
                        Animation.easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true),
                        value: viewModel.isAnimating
                    )
                    .onAppear {
                        viewModel.isAnimating = true
                    }
            }

            VStack {
                Spacer()

                Text(viewModel.formattedElapsedTime())
                    .font(.custom("zixiaohunnaitangti_T", size: 28))
                    .tracking(3)
                    .bold()
                    .padding(.top, -1)
                HStack {
                    Text("❤️")
                        .font(.system(size: 14))
                        .opacity(0.8)

                    if viewModel.isShaking {
                        Text(String(viewModel.heartRateMeasurementService.currentHeartRate))
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.8)
                    } else {
                        Text("0")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.8)
                    }
                }
                .padding(.top, -1)

                Spacer()

                Button(action: {
                    viewModel.toggleSession()
                }) {
                    Text(viewModel.isShaking ? "🤒结束挤奶" : "🥵开始挤奶")
                        .font(.custom("zixiaohunnaitangti_T", size: 16))
                }
                .padding(.bottom)
                Text(viewModel.statsText)
                    .font(.custom("zixiaohunnaitangti_T", size: 11))
                    .opacity(0.9)
                    .padding(.bottom, 20)
            }
            .onAppear {
                viewModel.onAppear()
            }
            .blur(radius: viewModel.vsBlur)
            .opacity(viewModel.vsOpacity)

            if viewModel.showSummary {
                ScrollView {
                    VStack {
                        Text("🥰奶桶已满")
                            .font(.custom("zixiaohunnaitangti_T", size: 24))
                            .padding(.top, 30)

                        Text("适当控制挤奶次数，可有效防止奶源枯竭")
                            .font(.custom("zixiaohunnaitangti_T", size: 10))
                            .multilineTextAlignment(.center)
                            .padding(.top, -1)
                            .opacity(0.6)

                        VStack {
                            HStack {
                                Text("⏱用时")
                                    .font(.custom("zixiaohunnaitangti_T", size: 12))
                                    .opacity(0.9)

                                Spacer()

                                Text(viewModel.formattedElapsedTime())
                                    .font(.custom("zixiaohunnaitangti_T", size: 14))
                            }
                            .padding(.bottom)

                            HStack {
                                Text("👋次数")
                                    .font(.custom("zixiaohunnaitangti_T", size: 12))
                                    .opacity(0.9)

                                Spacer()

                                Text(String(viewModel.shakeCount))
                                    .font(.custom("zixiaohunnaitangti_T", size: 14))
                            }
                            .padding(.bottom)

                            HStack {
                                Text("👌频率")
                                    .font(.custom("zixiaohunnaitangti_T", size: 12))
                                    .opacity(0.9)

                                Spacer()

                                Text(viewModel.summaryFrequencyText + "次/秒")
                                    .font(.custom("zixiaohunnaitangti_T", size: 14))
                            }
                            .padding(.bottom)

                            HStack {
                                Text("💗心率")
                                    .font(.custom("zixiaohunnaitangti_T", size: 12))
                                    .opacity(0.9)

                                Spacer()

                                Text(viewModel.summaryAverageHeartRateText)
                                    .font(.custom("zixiaohunnaitangti_T", size: 14))
                            }
                            .padding(.bottom, 20)
                        }
                        .padding(.top, 20)
                    }
                }
                .background(
                    Color.black
                        .blur(radius: 100)
                        .edgesIgnoringSafeArea(.all)
                        .opacity(0.8)
                )
            }
        }
    }
}

#Preview {
    PlayView()
}
