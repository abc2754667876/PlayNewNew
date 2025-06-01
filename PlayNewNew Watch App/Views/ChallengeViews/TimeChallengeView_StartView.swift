//
//  TimeChallengeView_StartView.swift
//  PlayNewNew
//
//  Created by Chengzhi 张 on 2024/10/19.
//

import SwiftUI
import CoreMotion
import AVFoundation

struct TimeChallengeView_StartView: View {
    @State private var countdownFinished = false
    
    var body: some View {
        if countdownFinished{
            TimeChallengeView_StartView_ChallengeView()
        }
        else{
            TimeChallengeView_CountdownView(countdownFinished: $countdownFinished)
        }
    }
}

struct TimeChallengeView_CountdownView: View{
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

struct TimeChallengeView_StartView_ChallengeView: View {
    @State private var elapsedTime = 0
    @State private var shakeCount = 0
    @State private var isShaking = true
    
    @State private var startTime: Date?
    @State private var lastShakeTime: Date?
    
    @State private var timer: Timer?
    private let motionManager = CMMotionManager()
    
    @State private var audioPlayer_end: AVAudioPlayer?
    
    @StateObject private var workoutManager = WorkoutManager()
    
    @AppStorage("isSoundOpen") private var isSoundOpen = true
    
    @AppStorage("accelerationThreshold") private var accelerationThreshold = 0.5
    @AppStorage("timeThreshold") private var timeThreshold = 0.34
    
    var body: some View {
        ZStack{
            Text("⏰")
                .font(.system(size: 150))
                .opacity(0.2)
                .blur(radius: 4)
            
            if isShaking {
                VStack{
                    Spacer()
                    
                    Text("⏰时长挑战开始")
                        .font(.custom("zixiaohunnaitangti_T", size:18))
                    
                    Text(formatTime(elapsedTime))
                        .font(.custom("zixiaohunnaitangti_T", size:28))
                        .tracking(3)
                        .bold()
                        .padding(.top)
                    
                    Spacer()
                    
                    Button(action: {
                        stopShaking()
                    }){
                        Text("结束挑战")
                            .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom, 1)
                    
                    Text("🍼已挤奶\(shakeCount)下")
                        .font(.custom("zixiaohunnaitangti_T", size:13))
                        .padding(.bottom, 5)
                }
            } else {
                VStack{
                    Text("时长挑战结束")
                        .font(.custom("zixiaohunnaitangti_T", size:20))
                        .padding(.bottom, 20)
                    
                    Text("⏱挑战用时：\(formatTime(elapsedTime))")
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
            if isSoundOpen{
                prepareSound_end()
            }
        }
    }
    
    private func startShaking(){
        workoutManager.startWorkout()
        
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let startTime = self.startTime {
                self.elapsedTime = Int(Date().timeIntervalSince(startTime))
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
        isShaking = false
        workoutManager.endWorkout()
        
        // Stop the timer
        timer?.invalidate()
        timer = nil
        
        // Stop motion detection
        motionManager.stopDeviceMotionUpdates()
        playSound_end()
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

#Preview {
    TimeChallengeView_StartView_ChallengeView()
}
