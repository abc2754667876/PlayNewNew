//
//  SettingView.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/8/20.
//

import SwiftUI

struct SettingView: View {
    @StateObject private var viewModel = SettingViewModel()
    @AppStorage("isSoundOpen") private var isSoundOpen = true

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Text("⚙ 通用设置")
                            .font(.custom("zixiaohunnaitangti_T", size: 15))
                        Spacer()
                    }
                    .padding(.top, 25)

                    HStack {
                        Text("播放音效")
                            .font(.custom("zixiaohunnaitangti_T", size: 14))

                        Spacer()

                        Toggle("", isOn: $isSoundOpen)
                            .padding()
                    }

                    Divider()
                        .padding(.bottom)

                    HStack {
                        Text("⚙ 挤奶灵敏度设置")
                            .font(.custom("zixiaohunnaitangti_T", size: 15))
                        Spacer()
                    }

                    NavigationLink(destination: SettingView_AccelerationThresholdSetting()) {
                        Text("挤奶灵敏度设置")
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)
                    .padding(.top)

                    Divider()
                        .padding(.bottom)

                    Button(action: {
                        viewModel.clearAllRecords()
                    }) {
                        Text("清除挤奶数据")
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                            .foregroundStyle(.red)
                    }

                    Text("当前版本：\(viewModel.appVersion)")
                        .padding(.top, 5)
                        .font(.custom("zixiaohunnaitangti_T", size: 12))
                        .opacity(0.7)

                    Spacer()
                }
                .alert(isPresented: $viewModel.showAlert) {
                    Alert(
                        title: Text("提示"),
                        message: Text(viewModel.alertInfo),
                        dismissButton: .default(Text("确定"))
                    )
                }
            }
        }
    }
}

#Preview {
    SettingView()
}
