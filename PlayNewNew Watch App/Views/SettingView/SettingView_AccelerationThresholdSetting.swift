//
//  SettingView_AccelerationThresholdSetting.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/9/21.
//

import SwiftUI

struct SettingView_AccelerationThresholdSetting: View {
    @AppStorage("accelerationThreshold") private var accelerationThreshold = 0.5
    @AppStorage("timeThreshold") private var timeThreshold = 0.34
    @StateObject private var viewModel = AccelerationThresholdSettingViewModel()

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("加速度敏感值(\(accelerationThreshold, specifier: "%.2f"))")
                        .font(.custom("zixiaohunnaitangti_T", size: 14))
                    Spacer()
                }

                Slider(value: $accelerationThreshold, in: 0.1...5, step: 0.1)
                    .padding()

                Text("加速度敏感值是指手表内的加速度传感器所读出的加速度值大于设定的敏感值才记录挤奶的有效次数")
                    .font(.custom("zixiaohunnaitangti_T", size: 12))
                    .opacity(0.7)

                Divider()
                    .padding(.top)
                    .padding(.bottom)

                HStack {
                    Text("时间敏感值(\(timeThreshold, specifier: "%.2f")s)")
                        .font(.custom("zixiaohunnaitangti_T", size: 14))
                    Spacer()
                }

                Slider(value: $timeThreshold, in: 0.01...1, step: 0.01)
                    .padding()

                Text("时间敏感值是指间隔至少多长时间才记录下一次挤奶的次数")
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

                Button(action: { viewModel.resetToDefaults() }) {
                    Text("恢复默认值")
                        .font(.custom("zixiaohunnaitangti_T", size: 14))
                }
                .padding(.bottom)
            }
            .onDisappear {
                viewModel.onDisappear()
            }
        }
    }
}

#Preview {
    SettingView_AccelerationThresholdSetting()
}
