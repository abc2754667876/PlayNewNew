//
//  EdgeChallengeView_StartView.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/9/17.
//

import SwiftUI
import CoreMotion
import AVFoundation

struct EdgeChallengeView_StartView: View {
    @State private var countdownFinished = false
    
    var body: some View {
        if countdownFinished{
            EdgeChallengeView_StartView_ChallengeView()
        }
        else{
            EdgeChallengeView_CountdownView(countdownFinished: $countdownFinished)
        }
    }
}

struct EdgeChallengeView_CountdownView: View{
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

struct EdgeChallengeView_StartView_ChallengeView: View{
    @State private var statusText: String = "现在是：挤奶时间"
    @State private var isMilking: Bool = true
    @State private var timer: Timer? = nil
    @State private var countdown: Int = 10
    @State private var rounds: Int = 1
    @State private var milkingCompleted: Bool = false
    
    @State private var shakeTimer: Timer? = nil
    private let motionManager = CMMotionManager()
    @State private var lastShakeTime: Date?
    @State private var shakeCount = 0
    @State private var lastShakeCount = 0
    @State private var noMilkingTime: Int = 0
    
    @State private var audioPlayer_end: AVAudioPlayer?
    @AppStorage("isSoundOpen") private var isSoundOpen = true
    
    @AppStorage("accelerationThreshold") private var accelerationThreshold = 0.5
    @AppStorage("timeThreshold") private var timeThreshold = 0.34
    
    @StateObject private var workoutManager = WorkoutManager()
    
    var body: some View{
        ZStack{
            Text("🤞")
                .font(.system(size: 150))
                .opacity(0.2)
                .blur(radius: 4)
            
            if milkingCompleted{
                VStack{
                    Text("🤞边缘挑战完成")
                        .font(.custom("zixiaohunnaitangti_T", size:20))
                    Text("本次坚持了\(rounds - 1)轮")
                        .font(.custom("zixiaohunnaitangti_T", size:14))
                        .padding(.top)
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                }
            }
            else{
                VStack{
                    Text("🤞边缘挑战开始-第\(rounds)轮")
                        .font(.custom("zixiaohunnaitangti_T", size:12))
                        .padding(.top, 30)
                        .padding(.bottom, 5)
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                    
                    Text(statusText)
                        .font(.custom("zixiaohunnaitangti_T", size:18))
                    
                    Spacer()
                    
                    Text("\(countdown)")
                        .font(.custom("zixiaohunnaitangti_T", size:48))
                    
                    Spacer()
                    
                    Text("👋已挤奶\(shakeCount)下")
                        .font(.custom("zixiaohunnaitangti_T", size:13))
                        .opacity(0.9)
                        .padding(.bottom)
                }

            }
        }
        .onAppear{
            startMilking()
            startMonitorShake()
            if isSoundOpen{
                prepareSound_end()
            }
        }
    }
    
    func startMilking() {
        // 启动一个10秒倒计时并每秒更新状态
        countdown = 10
        statusText = "现在是：挤奶时间"
        lastShakeCount = shakeCount
        workoutManager.startWorkout()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            countdown -= 1
            if isMilking {
                monitorMilkingActivity() // 仅在“正在挤奶”时监控挤奶次数是否增加
            }
            
            if countdown <= 0 {
                switchStatus()
            }
        }
    }
    
    func switchStatus() {
        if isMilking {
            // 切换到“休息中”，倒计时5秒
            statusText = "现在是：休息时间"
            countdown = 5
        } else {
            // 切换回“正在挤奶”，倒计时10秒
            statusText = "现在是：挤奶时间"
            countdown = 10
            rounds += 1
            noMilkingTime = 0
            lastShakeCount = shakeCount
        }
        
        isMilking.toggle() // 切换状态
    }
    
    func stopMilking() {
        // 停止计时器并结束状态
        timer?.invalidate()
        timer = nil
        milkingCompleted = true
        workoutManager.endWorkout()
    }
    
    func monitorMilkingActivity() {
        // 仅在“正在挤奶”状态时检测挤奶次数是否增加
        if shakeCount == lastShakeCount {
            noMilkingTime += 1 // 未挤奶时间增加
        } else {
            noMilkingTime = 0 // 挤奶次数增加时重置未挤奶时间
            lastShakeCount = shakeCount // 更新上一次挤奶次数
        }

        // 如果3秒内挤奶次数没有增加，停止挤奶
        if noMilkingTime >= 4 {
            stopMilking()
            playSound_end()
        }
    }
    
    func startMonitorShake(){
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

                    if isMilking {
                        self.shakeCount += 1
                    }
                    self.lastShakeTime = now
                }
            }
        }
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
    //EdgeChallengeView_StartView()
    EdgeChallengeView_StartView_ChallengeView()
}
