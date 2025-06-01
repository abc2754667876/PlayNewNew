//
//  FrequencyChallengeView.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/9/9.
//

import SwiftUI
import AVFoundation

struct FrequencyChallengeView: View {
    @State private var selectedNumber = 1 // 默认选择的数字
    let numbers = Array(1...30) // 数字范围
    
    @State private var timer: Timer?
    @State private var isVibrating = false
    
    @State private var buttonText = "感受频率"
    
    var body: some View {
        NavigationView{
            ZStack{
                Text("👌")
                    .font(.system(size: 150))
                    .opacity(0.2)
                    .blur(radius: 4)
                
                ScrollView{
                    VStack{
                        Text("👌频率挑战")
                            .font(.custom("zixiaohunnaitangti_T", size:20))
                            .padding(.top, 30)
                        
                        HStack{
                            Text("选择频率：")
                                .font(.custom("zixiaohunnaitangti_T", size:13))
                            Spacer()
                        }
                        .padding(.top, 15)

                        Picker("", selection: $selectedNumber) {
                            ForEach(numbers, id: \.self) { number in
                                Text("\(number)").tag(number)
                                    .font(.custom("zixiaohunnaitangti_T", size:13))
                            }
                        }
                        .frame(height: 50)
                        .pickerStyle(.wheel) // 使用滚轮样式
                        
                        Text("即每秒摇晃手臂\(selectedNumber)个来回")
                            .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                            .padding(.top, 3)
                            .padding(.bottom)
                        
                        Button(action: {
                            if isVibrating{
                                buttonText = "感受频率"
                                stopVibration()
                            } else {
                                buttonText = "停止感受"
                                startVibration()
                            }
                        }){
                            Text(buttonText)
                                .font(.custom("zixiaohunnaitangti_T", size:14))
                        }
                        
                        NavigationLink(destination: FrequencyChallengeView_StartView(vibratefrequency: $selectedNumber)){
                            Text("进入挑战")
                                .font(.custom("zixiaohunnaitangti_T", size:14))
                                .foregroundStyle(.red)
                        }
                        .padding(.top, 5)
                        .padding(.bottom)
                        
                        Text("提示：跟随震动摇晃手臂,停止摇晃三秒后自动结束")
                            .font(.custom("zixiaohunnaitangti_T", size:12))
                            .padding(.bottom)
                            .multilineTextAlignment(.center)
                            .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                    }
                }
            }
            .onDisappear{
                stopVibration()
            }
        }
    }

    // 开始按一定频率震动
    private func startVibration() {
        if isVibrating { return }
        isVibrating = true
        
        let interval = 1.0 / Double(selectedNumber)
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            WKInterfaceDevice.current().play(.directionDown)
        }
    }
    
    // 停止震动
    private func stopVibration() {
        isVibrating = false
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    FrequencyChallengeView()
}
