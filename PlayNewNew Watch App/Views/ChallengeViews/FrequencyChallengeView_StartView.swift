//
//  FrequencyChallengeView_StartView.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/9/9.
//

import SwiftUI
import CoreMotion
import AVFoundation

struct FrequencyChallengeView_StartView: View {
    @State private var countdownFinished = false
    @Binding var vibratefrequency: Int
    
    var body: some View {
        if countdownFinished{
            FrequencyChallengeView_StartView_ChallengeView(vibratefrequency: $vibratefrequency)
        }
        else{
            FrequencyChallengeView_CountdownView(countdownFinished: $countdownFinished)
        }
    }
}

struct FrequencyChallengeView_CountdownView: View{
    @State private var currentCountdownIndex = 0
    @State private var isAnimating = false
    @Binding var countdownFinished: Bool
    
    let countdownNumbers = ["6", "5", "4", "3", "2", "1"]

    var body: some View {
        ZStack {
            ForEach(0..<countdownNumbers.count, id: \.self) { index in
                if currentCountdownIndex == index {
                    Text(countdownNumbers[index])
                        .font(.custom("zixiaohunnaitangti_T", size:100))
                        .scaleEffect(isAnimating ? 1.0 : 0.1)
                        .opacity(isAnimating ? 1.0 : 0.0) // 控制显示/消失
                        .blur(radius: isAnimating ? 0.0 : 15.0)
                        .animation(.easeInOut(duration: 0.5), value: isAnimating)
                }
            }
        }
        .onAppear{
            startCountdown()
        }
    }

    // 开始倒计时
    private func startCountdown() {
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if currentCountdownIndex < countdownNumbers.count {
                isAnimating = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isAnimating = false
                }
                currentCountdownIndex += 1
            } else {
                timer.invalidate()
                countdownFinished = true // 倒计时结束后切换视图
            }
        }
        RunLoop.current.add(timer, forMode: .common)
    }
}

struct FrequencyChallengeView_StartView_ChallengeView: View{
    @State private var elapsedTime = 0
    @State private var shakeCount = 0
    @State private var isShaking = true
    
    @State private var startTime: Date?
    @State private var lastShakeTime: Date?
    
    @State private var timer: Timer?
    private let motionManager = CMMotionManager()
    
    @Binding var vibratefrequency: Int
    @State private var vibrateTimer: Timer?
    @State private var isVibrating = false
    
    @State private var audioPlayer_end: AVAudioPlayer?
    
    @StateObject private var workoutManager = WorkoutManager()
    
    @AppStorage("isSoundOpen") private var isSoundOpen = true
    
    @AppStorage("accelerationThreshold") private var accelerationThreshold = 0.5
    @AppStorage("timeThreshold") private var timeThreshold = 0.34
    
    var body: some View{
        ZStack{
            Text("👌")
                .font(.system(size: 150))
                .opacity(0.2)
                .blur(radius: 4)
            if isShaking{
                VStack{
                    Spacer()
                    
                    Text("👌频率挑战开始")
                        .font(.custom("zixiaohunnaitangti_T", size:18))
                    
                    Text(formatTime(elapsedTime))
                        .font(.custom("zixiaohunnaitangti_T", size:28))
                        .tracking(3)
                        .bold()
                        .padding(.top)
                    
                    Spacer()
                    
                    Text("🍼已挤奶\(shakeCount)下")
                        .font(.custom("zixiaohunnaitangti_T", size:13))
                        .padding(.bottom, 5)
                    
                    Text("停止挤奶三秒后自动结束挑战")
                        .font(.custom("zixiaohunnaitangti_T", size:10))
                        .opacity(0.7)
                        .padding(.bottom, 10)
                }
            }
            else{
                VStack{
                    Text("频率挑战结束")
                        .font(.custom("zixiaohunnaitangti_T", size:20))
                        .padding(.bottom, 20)
                    
                    Text("👋目标频率：\(vibratefrequency)下/秒")
                        .font(.custom("zixiaohunnaitangti_T", size:13))
                        .padding(.bottom, 5)
                    Text("⏱实际用时：\(formatTime(elapsedTime - 3))")
                        .font(.custom("zixiaohunnaitangti_T", size:13))
                        .padding(.bottom, 5)
                    Text("👋摇晃次数：\(shakeCount)")
                        .font(.custom("zixiaohunnaitangti_T", size:13))
                }
            }
        }
        .onAppear{
            self.lastShakeTime = Date()
            startShaking()
            startVibration()
            if isSoundOpen{
                prepareSound_end()
            }
        }
        .onDisappear{
            stopVibration()
        }
    }
    
    private func startShaking(){
        workoutManager.startWorkout()
        
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let startTime = self.startTime {
                self.elapsedTime = Int(Date().timeIntervalSince(startTime))
            }
            
            let now = Date()
            if now.timeIntervalSince(self.lastShakeTime!) > 4.0 {
                stopShaking()
            }
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
                    self.lastShakeTime = now
                }
            }
        }
    }
    
    private func stopShaking() {
        stopVibration()
        isShaking = false
        workoutManager.endWorkout()
        
        // Stop the timer
        timer?.invalidate()
        timer = nil
        
        // Stop motion detection
        motionManager.stopDeviceMotionUpdates()
        playSound_end()
    }
    
    private func startVibration() {
        if isVibrating { return }
        isVibrating = true
        
        let interval = 1.0 / Double(vibratefrequency)
        
        vibrateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            WKInterfaceDevice.current().play(.directionDown)
        }
    }
    
    // 停止震动
    private func stopVibration() {
        isVibrating = false
        vibrateTimer?.invalidate()
        vibrateTimer = nil
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
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
