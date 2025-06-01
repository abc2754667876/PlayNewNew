//
//  SettingView.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/8/20.
//

import SwiftUI
import Combine

struct SettingView: View {
    @State private var clear_ShowAlert = false
    @State private var clear_IsConfirmed = false
    
    @AppStorage("isSoundOpen") private var isSoundOpen = true
    @State private var showAlert: Bool = false
    @State private var alertInfo: String = ""
    
    @State private var debugMode = false
    
    @State private var cancellable: AnyCancellable?
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack{
                    HStack{
                        Text("⚙ 通用设置")
                            .font(.custom("zixiaohunnaitangti_T", size:15))
                        Spacer()
                    }
                    .padding(.top, 25)
                    
                    HStack{
                        Text("播放音效")
                            .font(.custom("zixiaohunnaitangti_T", size:14))
                        
                        Spacer()
                        
                        Toggle("", isOn: $isSoundOpen)
                            .padding()
                    }
                    
                    Divider()
                        .padding(.bottom)
                    
                    HStack{
                        Text("⚙ 挤奶灵敏度设置")
                            .font(.custom("zixiaohunnaitangti_T", size:15))
                        Spacer()
                    }
                    
                    NavigationLink(destination: SettingView_AccelerationThresholdSetting()){
                        Text("挤奶灵敏度设置")
                            .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    .padding(.top)
                    
                    Divider()
                        .padding(.bottom)
                    
                    Button(action:{
                        clearDataRecords()
                    }){
                        Text("清除挤奶数据")
                            .font(.custom("zixiaohunnaitangti_T", size:14))
                            .foregroundStyle(.red)
                    }
                    
                    Text("当前版本：\(appVersion)")
                        .padding(.top, 5)
                        .font(.custom("zixiaohunnaitangti_T", size:12))
                        .opacity(0.7)
                    
                    Spacer()
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("提示"),
                        message: Text(alertInfo),
                        dismissButton: .default(Text("确定"))
                    )
                }
                .onDisappear{
                    cancellable?.cancel()
                }
            }
        }
    }
    
    var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "未知"
    }
}

#Preview {
    SettingView()
}
