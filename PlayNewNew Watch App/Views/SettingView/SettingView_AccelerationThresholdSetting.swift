//
//  SettingView_AccelerationThresholdSetting.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/9/21.
//

import SwiftUI
import CoreMotion

struct SettingView_AccelerationThresholdSetting: View {
    @AppStorage("accelerationThreshold") private var accelerationThreshold = 0.5
    @AppStorage("timeThreshold") private var timeThreshold = 0.34
    @State private var shakeCount = 0
    private let motionManager = CMMotionManager()
    @State private var isStart = false
    @State private var startTime: Date?
    @State private var lastShakeTime: Date?
    @StateObject private var workoutManager = WorkoutManager()
    
    @State private var x_ = 0.0
    @State private var y_ = 0.0
    @State private var z_ = 0.0
    
    var body: some View {
        ScrollView{
            VStack{
                HStack{
                    Text("加速度敏感值(\(accelerationThreshold, specifier: "%.2f"))")
                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    Spacer()
                }
                
                Slider(value: $accelerationThreshold, in: 0.1...5, step: 0.1)
                    .padding()
                
                Text("加速度敏感值是指手表内的加速度传感器所读出的加速度值大于设定的敏感值才记录挤奶的有效次数")
                    .font(.custom("zixiaohunnaitangti_T", size:12))
                    .opacity(0.7)
                
                Divider()
                    .padding(.top)
                    .padding(.bottom)
                
                HStack{
                    Text("时间敏感值(\(timeThreshold, specifier: "%.2f")s)")
                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    Spacer()
                }
                
                Slider(value: $timeThreshold, in: 0.01...1, step: 0.01)
                    .padding()
                
                Text("时间敏感值是指间隔至少多长时间才记录下一次挤奶的次数")
                    .font(.custom("zixiaohunnaitangti_T", size:12))
                    .opacity(0.7)
                
                Divider()
                    .padding(.top)
                    .padding(.bottom)
                
                HStack{
                    Text("测试一下")
                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    Spacer()
                }
                
                Button(action: {
                    if isStart{
                        stopMotion()
                    }
                    else {
                        startMotion()
                    }
                }){
                    Text(isStart ? "结束测试" : "开始测试")
                        .font(.custom("zixiaohunnaitangti_T", size:14))
                }
                .padding(.top)
                
                Text("🍼已挤奶\(shakeCount)下")
                    .font(.custom("zixiaohunnaitangti_T", size:14))
                    .padding(.top)
                
                Divider()
                    .padding(.top)
                    .padding(.bottom)
                
                HStack{
                    Text("加速度传感器值")
                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    Spacer()
                }
                .padding(.bottom)
                
                HStack{
                    Text("x:\(x_, specifier: "%.2f")")
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                    Spacer()
                }
                HStack{
                    Text("y:\(y_, specifier: "%.2f")")
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                    Spacer()
                }
                HStack{
                    Text("z:\(z_, specifier: "%.2f")")
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                    Spacer()
                }

                
                Divider()
                    .padding(.top)
                    .padding(.bottom)
                
                Button(action: {
                    accelerationThreshold = 0.5
                    timeThreshold = 0.34
                }){
                    Text("恢复默认值")
                        .font(.custom("zixiaohunnaitangti_T", size:14))
                }
                .padding(.bottom)
            }
            .onDisappear{
                stopMotion()
                workoutManager.endWorkout()
            }
        }
    }
    
    private func startMotion(){
        isStart = true
        workoutManager.startWorkout()
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { motion, error in
            if let motion = motion {
                // Detect shaking motion with a time delay
                let acceleration = motion.userAcceleration
                let threshold: Double = accelerationThreshold
                let now = Date()

                x_ = acceleration.x
                y_ = acceleration.y
                z_ = acceleration.z
                
                if (acceleration.z > threshold || acceleration.z < -threshold) || (acceleration.y > threshold || acceleration.y < -threshold) || (acceleration.x > threshold || acceleration.x < -threshold) {
                    // If the last shake was detected less than 0.5 seconds ago, ignore it
                    if let lastShakeTime = self.lastShakeTime, now.timeIntervalSince(lastShakeTime) < timeThreshold {
                        return
                    }
                    if isStart{
                        self.shakeCount += 1
                    }
                    self.lastShakeTime = now
                }
            }
        }
    }
    
    private func stopMotion(){
        isStart = false
        workoutManager.endWorkout()
        shakeCount = 0
        motionManager.stopDeviceMotionUpdates()
    }
}

#Preview {
    SettingView_AccelerationThresholdSetting()
}
