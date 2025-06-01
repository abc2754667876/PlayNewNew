//
//  PlayView.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/8/12.
//

import SwiftUI
import HealthKit
import CoreMotion
import AVFoundation
import Foundation

struct PlayView: View {
    @State private var isShaking = false
    @State private var isStart = false
    @State private var shakeCount = 0
    @State private var elapsedTime = 0
    @State private var timer: Timer?
    @State private var startTime: Date?
    @State private var statsText: String = "👋点击按钮后开始为牛牛挤奶"
    @State private var lastShakeTime: Date?
    @State private var audioPlayer_end: AVAudioPlayer?
    @State private var audioPlayer_start: AVAudioPlayer?
    @State private var showSummary = false
    
    @State private var vsBlur: Double = 0
    @State private var vsOpacity: Double = 1.0
    
    private let motionManager = CMMotionManager()
    
    @ObservedObject var heartRateMeasurementService = HeartRateMeasurementService()
    @State private var heartRateArray = [Int]()
    @State private var heartRateSum = 0
    @State private var heartRateCount = 0
    
    @AppStorage("isOpen") private var isOpen: Bool = false
    @AppStorage("userName") private var userName: String = ""
    
    @AppStorage("isSoundOpen") private var isSoundOpen = true
    
    @AppStorage("accelerationThreshold") private var accelerationThreshold = 0.5
    @AppStorage("timeThreshold") private var timeThreshold = 0.34
    
    @StateObject private var workoutManager = WorkoutManager()
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack{
            if heartRateMeasurementService.currentHeartRate > 20 {
                Text("❤️")
                    .font(.system(size: 150))
                    .opacity(0.2)
                    .blur(radius: 5)
                    .scaleEffect(isAnimating ? 1.0 : 0) // 通过 scaleEffect 控制放大和缩小
                    .animation(
                        Animation.easeInOut(duration: Double(60) / Double(heartRateMeasurementService.currentHeartRate) / 2)
                            .repeatForever(autoreverses: true), // 设置无限循环动画，自动反转
                        value: isAnimating
                    )
                    .onAppear {
                        isAnimating = true // 开始动画
                    }
            }
            else{
                Text("❤️")
                    .font(.system(size: 150))
                    .opacity(0.2)
                    .blur(radius: 5)
                    .scaleEffect(isAnimating ? 1.2 : 0.8) // 通过 scaleEffect 控制放大和缩小
                    .animation(
                        Animation.easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true), // 设置无限循环动画，自动反转
                        value: isAnimating
                    )
                    .onAppear {
                        isAnimating = true // 开始动画
                    }
            }
            
            VStack{
                Spacer()
                
                Text(formatTime(elapsedTime))
                    .font(.custom("zixiaohunnaitangti_T", size:28))
                    .tracking(3)
                    .bold()
                    .padding(.top, -1)
                HStack{
                    Text("❤️")
                        .font(.system(size: 14))
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                    
                    if isShaking{
                        Text(String(heartRateMeasurementService.currentHeartRate))
                            .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                    }else{
                        Text("0")
                            .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                    }
                }
                .padding(.top, -1)
                
                Spacer()
                
                Button(action: {
                    if isShaking {
                        stopShaking()
                        showSummary = true
                        if(showSummary == true){
                            vsBlur = 8
                            vsOpacity = 0.9
                        }
                        workoutManager.endWorkout()
                        if isSoundOpen{
                            playSound_end()
                        }
                        
                    } else {
                        startShaking()
                        workoutManager.startWorkout()
                    }
                }){
                    Text(isShaking ? "🤒结束挤奶" : "🥵开始挤奶")
                        .font(.custom("zixiaohunnaitangti_T", size:16))
                }
                .padding(.bottom)
                Text(statsText)
                    .font(.custom("zixiaohunnaitangti_T", size:11))
                    .opacity(0.9)
                    .padding(.bottom, 20)
            }
            .onAppear {
                prepareSound_end()
                prepareSound_start()
            }
            .blur(radius: vsBlur)
            .opacity(vsOpacity)
            
            if showSummary {
                ScrollView {
                    VStack {
                        Text("🥰奶桶已满")                        .font(.custom("zixiaohunnaitangti_T", size:24))
                            .padding(.top, 30)
                        
                        Text("适当控制挤奶次数，可有效防止奶源枯竭")
                            .font(.custom("zixiaohunnaitangti_T", size:10))
                            .multilineTextAlignment(.center)
                            .padding(.top, -1)
                            .opacity(0.6)
                        
                        VStack{
                            HStack{
                                Text("⏱用时")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                                    .opacity(0.9)
                                
                                Spacer()
                                
                                Text(formatTime(elapsedTime))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                            }
                            .padding(.bottom)
                            
                            HStack{
                                Text("👋次数")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                                    .opacity(0.9)
                                
                                Spacer()
                                
                                Text(String(shakeCount))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                            }
                            .padding(.bottom)
                            
                            HStack{
                                Text("👌频率")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                                    .opacity(0.9)
                                
                                Spacer()
                                
                                Text(String(format: "%.1f", Double(shakeCount) / Double(elapsedTime)) + "次/秒")                        .font(.custom("zixiaohunnaitangti_T", size:14))
                            }
                            .padding(.bottom)
                            
                            HStack{
                                Text("💗心率")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                                    .opacity(0.9)
                                
                                Spacer()
                                
                                Text(String(format: "%.1f", Double(heartRateSum) / Double(heartRateCount)))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                            }
                            .padding(.bottom, 20)
                        }
                        .padding(.top, 20)
                    }
                }
                .background(
                    Color.black // 设置为白色背景
                        .blur(radius: 100) // 应用模糊效果
                        .edgesIgnoringSafeArea(.all)
                        .opacity(0.8)
                )
            }
        }
    }
    
    private func startShaking() {
        isShaking = true
        shakeCount = 0
        elapsedTime = 0
        startTime = Date()
        statsText = "🍼已挤奶" + String(shakeCount) + "下"
        
        // Start the timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let startTime = self.startTime {
                self.elapsedTime = Int(Date().timeIntervalSince(startTime))
            }
            self.heartRateArray.append(heartRateMeasurementService.currentHeartRate)
        }
        
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { motion, error in
            if let motion = motion {
                // Detect shaking motion with a time delay
                let acceleration = motion.userAcceleration
                let threshold: Double = accelerationThreshold
                let now = Date()

                if (acceleration.z > threshold || acceleration.z < -threshold) || (acceleration.y > threshold || acceleration.y < -threshold) || (acceleration.x > threshold || acceleration.x < -threshold) {
                    // If the last shake was detected less than 0.5 seconds ago, ignore it
                    if let lastShakeTime = self.lastShakeTime, now.timeIntervalSince(lastShakeTime) < timeThreshold {
                        return
                    }

                    self.shakeCount += 1
                    if(shakeCount >= 3 && isStart == false){
                        self.isStart = true
                        if isSoundOpen{
                            playSound_start()
                        }
                    }
                    
                    statsText = "🍼已挤奶" + String(shakeCount) + "下"
                    self.lastShakeTime = now
                }
            }
        }
    }
    
    private func stopShaking() {
        self.heartRateSum = heartRateArray.reduce(0, +)
        self.heartRateCount = heartRateArray.count
        
        isShaking = false
        
        // Stop the timer
        timer?.invalidate()
        timer = nil
        
        // Stop motion detection
        motionManager.stopDeviceMotionUpdates()
        
        let saveData = DataRecord(date: Date(), spend: elapsedTime, count: shakeCount, frequency: Double(shakeCount) / Double(elapsedTime), heartRate: Double(heartRateSum) / Double(heartRateCount))
        saveDataRecord(saveData)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func formatDateAndTime(date: Date) -> String {
        // 创建一个 DateFormatter 实例
        let formatter = DateFormatter()
        
        // 设置日期格式
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // 将 Date 格式化为字符串
        let formattedDate = formatter.string(from: date)
        
        return formattedDate
    }
    
    private func prepareSound_start() {
        // 准备音频文件
        if let soundURL = Bundle.main.url(forResource: "start", withExtension: "mp3") {
            do {
                audioPlayer_start = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer_start?.prepareToPlay() // 提前加载音频，防止播放延迟
            } catch {
                print("无法加载音频文件: \(error.localizedDescription)")
            }
        }
    }

    private func playSound_start() {
        audioPlayer_start?.play()
    }
    
    private func prepareSound_end() {
        // 准备音频文件
        if let soundURL = Bundle.main.url(forResource: "end", withExtension: "mp3") {
            do {
                audioPlayer_end = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer_end?.prepareToPlay() // 提前加载音频，防止播放延迟
            } catch {
                print("无法加载音频文件: \(error.localizedDescription)")
            }
        }
    }

    private func playSound_end() {
        audioPlayer_end?.play()
    }
}

#Preview {
    PlayView()
}
