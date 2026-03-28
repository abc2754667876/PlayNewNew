//
//  SettingView_AccelerationThresholdSetting.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/9/21.
//

import SwiftUI

struct SettingView_AccelerationThresholdSetting: View {
    @AppStorage(ShakeDetectionConfiguration.Keys.peakThreshold) private var peakThreshold = ShakeDetectionConfiguration.defaultValue.peakThreshold
    @AppStorage(ShakeDetectionConfiguration.Keys.resetThreshold) private var resetThreshold = ShakeDetectionConfiguration.defaultValue.resetThreshold
    @AppStorage(ShakeDetectionConfiguration.Keys.minimumPeakInterval) private var minimumPeakInterval = ShakeDetectionConfiguration.defaultValue.minimumPeakInterval
    @AppStorage(ShakeDetectionConfiguration.Keys.smoothingFactor) private var smoothingFactor = ShakeDetectionConfiguration.defaultValue.smoothingFactor
    @AppStorage(ShakeDetectionConfiguration.Keys.directionConfidenceThreshold) private var directionConfidenceThreshold = ShakeDetectionConfiguration.defaultValue.directionConfidenceThreshold
    @StateObject private var viewModel = AccelerationThresholdSettingViewModel()

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("主峰阈值(\(peakThreshold, specifier: "%.2f"))")
                        .font(.custom("zixiaohunnaitangti_T", size: 14))
                    Spacer()
                }

                Slider(value: $peakThreshold, in: 0.40...2.50, step: 0.05)
                    .padding()
                    .onChange(of: peakThreshold) { _ in
                        persistConfiguration()
                    }

                Text("主峰阈值越高，越需要更明显的发力峰值才会计数，用来抑制日常摆腕和轻微抖动误判。")
                    .font(.custom("zixiaohunnaitangti_T", size: 12))
                    .opacity(0.7)

                Divider()
                    .padding(.top)
                    .padding(.bottom)

                HStack {
                    Text("复位阈值(\(resetThreshold, specifier: "%.2f"))")
                        .font(.custom("zixiaohunnaitangti_T", size: 14))
                    Spacer()
                }

                Slider(value: $resetThreshold, in: 0.05...1.20, step: 0.01)
                    .padding()
                    .onChange(of: resetThreshold) { _ in
                        persistConfiguration()
                    }

                Text("复位阈值用于要求一次有效摇晃后必须明显回摆，只有完成回摆复位后，下一次峰值才会被再次计数。")
                    .font(.custom("zixiaohunnaitangti_T", size: 12))
                    .opacity(0.7)

                Divider()
                    .padding(.top)
                    .padding(.bottom)

                HStack {
                    Text("最短计数间隔(\(minimumPeakInterval, specifier: "%.2f")s)")
                        .font(.custom("zixiaohunnaitangti_T", size: 14))
                    Spacer()
                }

                Slider(value: $minimumPeakInterval, in: 0.08...0.80, step: 0.01)
                    .padding()
                    .onChange(of: minimumPeakInterval) { _ in
                        persistConfiguration()
                    }

                Text("最短计数间隔是工程层面的保险丝，避免同一次发力峰在高采样频率下被连续重复计数。")
                    .font(.custom("zixiaohunnaitangti_T", size: 12))
                    .opacity(0.7)

                Divider()
                    .padding(.top)
                    .padding(.bottom)

                HStack {
                    Text("平滑系数(\(smoothingFactor, specifier: "%.2f"))")
                        .font(.custom("zixiaohunnaitangti_T", size: 14))
                    Spacer()
                }

                Slider(value: $smoothingFactor, in: 0.05...0.50, step: 0.01)
                    .padding()
                    .onChange(of: smoothingFactor) { _ in
                        persistConfiguration()
                    }

                Text("平滑系数越高，响应越灵敏；越低，越稳定。手腕抖动噪声较大时可以适当降低。")
                    .font(.custom("zixiaohunnaitangti_T", size: 12))
                    .opacity(0.7)

                Divider()
                    .padding(.top)
                    .padding(.bottom)

                HStack {
                    Text("方向置信度(\(directionConfidenceThreshold, specifier: "%.2f"))")
                        .font(.custom("zixiaohunnaitangti_T", size: 14))
                    Spacer()
                }

                Slider(value: $directionConfidenceThreshold, in: 0.30...0.95, step: 0.01)
                    .padding()
                    .onChange(of: directionConfidenceThreshold) { _ in
                        persistConfiguration()
                    }

                Text("方向置信度用于判断当前动作是否集中在某一主方向上，数值越高，对胡乱甩动的过滤越严格。")
                    .font(.custom("zixiaohunnaitangti_T", size: 12))
                    .opacity(0.7)

                Divider()
                    .padding(.top)
                    .padding(.bottom)

                HStack {
                    Text("测试一下")
                        .font(.custom("zixiaohunnaitangti_T", size: 14))
                    Spacer()
                }

                Button(action: { viewModel.toggleTest() }) {
                    Text(viewModel.isStart ? "结束测试" : "开始测试")
                        .font(.custom("zixiaohunnaitangti_T", size: 14))
                }
                .padding(.top)

                Text("🍼已挤奶\(viewModel.shakeCount)下")
                    .font(.custom("zixiaohunnaitangti_T", size: 14))
                    .padding(.top)

                Divider()
                    .padding(.top)
                    .padding(.bottom)

                HStack {
                    Text("加速度传感器值")
                        .font(.custom("zixiaohunnaitangti_T", size: 14))
                    Spacer()
                }
                .padding(.bottom)

                HStack {
                    Text("x:\(viewModel.x, specifier: "%.2f")")
                        .opacity(0.8)
                    Spacer()
                }
                HStack {
                    Text("y:\(viewModel.y, specifier: "%.2f")")
                        .opacity(0.8)
                    Spacer()
                }
                HStack {
                    Text("z:\(viewModel.z, specifier: "%.2f")")
                        .opacity(0.8)
                    Spacer()
                }

                Divider()
                    .padding(.top)
                    .padding(.bottom)

                HStack {
                    Text("算法调试值")
                        .font(.custom("zixiaohunnaitangti_T", size: 14))
                    Spacer()
                }
                .padding(.bottom)

                HStack {
                    Text("状态:\(viewModel.detectorState)")
                        .opacity(0.8)
                    Spacer()
                }
                HStack {
                    Text("主方向:\(viewModel.dominantAxisText)")
                        .opacity(0.8)
                    Spacer()
                }
                HStack {
                    Text("平滑后模长:\(viewModel.filteredMagnitude, specifier: "%.2f")")
                        .opacity(0.8)
                    Spacer()
                }
                HStack {
                    Text("对齐后投影:\(viewModel.signedProjection, specifier: "%.2f")")
                        .opacity(0.8)
                    Spacer()
                }
                HStack {
                    Text("方向置信度:\(viewModel.directionConfidence, specifier: "%.2f")")
                        .opacity(0.8)
                    Spacer()
                }

                Divider()
                    .padding(.top)
                    .padding(.bottom)

                Button(action: { viewModel.resetToDefaults() }) {
                    Text("恢复默认值")
                        .font(.custom("zixiaohunnaitangti_T", size: 14))
                }
                .padding(.bottom)
            }
            .onDisappear {
                viewModel.onDisappear()
            }
            .onAppear {
                persistConfiguration()
            }
        }
    }

    private func persistConfiguration() {
        ShakeDetectionConfiguration(
            peakThreshold: peakThreshold,
            resetThreshold: resetThreshold,
            minimumPeakInterval: minimumPeakInterval,
            smoothingFactor: smoothingFactor,
            directionConfidenceThreshold: directionConfidenceThreshold,
            directionAdaptation: ShakeDetectionConfiguration.defaultValue.directionAdaptation,
            inactivityResetInterval: ShakeDetectionConfiguration.defaultValue.inactivityResetInterval,
            sampleInterval: ShakeDetectionConfiguration.defaultValue.sampleInterval
        ).persist()
    }
}

#Preview {
    SettingView_AccelerationThresholdSetting()
}
