//
//  PlayViewModel.swift
//  PlayNewNew Watch App
//

import SwiftUI
import CoreMotion
import AVFoundation
import Combine

final class PlayViewModel: ObservableObject {
    @Published var isShaking = false
    @Published var isStart = false
    @Published var shakeCount = 0
    @Published var elapsedTime = 0
    @Published var statsText = "👋点击按钮后开始为牛牛挤奶"
    @Published var showSummary = false
    @Published var vsBlur: Double = 0
    @Published var vsOpacity: Double = 1.0
    @Published var isAnimating = false
    @Published var heartRateSum = 0
    @Published var heartRateCount = 0

    let heartRateMeasurementService = HeartRateMeasurementService()
    private let workoutManager = WorkoutManager()
    private let motionManager = CMMotionManager()

    private var timer: Timer?
    private var startTime: Date?
    private var lastShakeTime: Date?
    private var heartRateArray = [Int]()
    private var audioPlayerEnd: AVAudioPlayer?
    private var audioPlayerStart: AVAudioPlayer?

    private var cancellables = Set<AnyCancellable>()

    init() {
        heartRateMeasurementService.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    var summaryAverageHeartRateText: String {
        guard heartRateCount > 0 else { return "0.0" }
        return String(format: "%.1f", Double(heartRateSum) / Double(heartRateCount))
    }

    var summaryFrequencyText: String {
        guard elapsedTime > 0 else { return "0.0" }
        return String(format: "%.1f", Double(shakeCount) / Double(elapsedTime))
    }

    func formattedElapsedTime() -> String {
        Self.formatTime(elapsedTime)
    }

    func onAppear() {
        prepareSoundEnd()
        prepareSoundStart()
    }

    func toggleSession() {
        if isShaking {
            stopShaking()
            showSummary = true
            vsBlur = 8
            vsOpacity = 0.9
            workoutManager.endWorkout()
            if Self.readSoundOpen() { playSoundEnd() }
        } else {
            startShaking()
            workoutManager.startWorkout()
        }
    }

    private func startShaking() {
        isShaking = true
        shakeCount = 0
        elapsedTime = 0
        isStart = false
        startTime = Date()
        statsText = "🍼已挤奶" + String(shakeCount) + "下"

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            if let startTime = self.startTime {
                self.elapsedTime = Int(Date().timeIntervalSince(startTime))
            }
            self.heartRateArray.append(self.heartRateMeasurementService.currentHeartRate)
        }

        let accelThreshold = Self.readAccelerationThreshold()
        let timeThresh = Self.readTimeThreshold()

        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] motion, _ in
            guard let self, let motion else { return }
            let acceleration = motion.userAcceleration
            let now = Date()

            if (acceleration.z > accelThreshold || acceleration.z < -accelThreshold)
                || (acceleration.y > accelThreshold || acceleration.y < -accelThreshold)
                || (acceleration.x > accelThreshold || acceleration.x < -accelThreshold) {
                if let lastShakeTime = self.lastShakeTime, now.timeIntervalSince(lastShakeTime) < timeThresh {
                    return
                }

                self.shakeCount += 1
                if self.shakeCount >= 3 && self.isStart == false {
                    self.isStart = true
                    if Self.readSoundOpen() { self.playSoundStart() }
                }

                self.statsText = "🍼已挤奶" + String(self.shakeCount) + "下"
                self.lastShakeTime = now
            }
        }
    }

    private func stopShaking() {
        heartRateSum = heartRateArray.reduce(0, +)
        heartRateCount = heartRateArray.count

        isShaking = false
        timer?.invalidate()
        timer = nil
        motionManager.stopDeviceMotionUpdates()

        let freq: Double
        if elapsedTime > 0 {
            freq = Double(shakeCount) / Double(elapsedTime)
        } else {
            freq = 0
        }
        let hrAvg: Double
        if heartRateCount > 0 {
            hrAvg = Double(heartRateSum) / Double(heartRateCount)
        } else {
            hrAvg = 0
        }
        let saveData = DataRecord(date: Date(), spend: elapsedTime, count: shakeCount, frequency: freq, heartRate: hrAvg)
        saveDataRecord(saveData)
    }

    private static func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    private static func readSoundOpen() -> Bool {
        if UserDefaults.standard.object(forKey: "isSoundOpen") == nil { return true }
        return UserDefaults.standard.bool(forKey: "isSoundOpen")
    }

    private static func readAccelerationThreshold() -> Double {
        let v = UserDefaults.standard.object(forKey: "accelerationThreshold")
        return (v as? Double) ?? 0.5
    }

    private static func readTimeThreshold() -> Double {
        let v = UserDefaults.standard.object(forKey: "timeThreshold")
        return (v as? Double) ?? 0.34
    }

    private func prepareSoundStart() {
        guard let soundURL = Bundle.main.url(forResource: "start", withExtension: "mp3") else { return }
        do {
            audioPlayerStart = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayerStart?.prepareToPlay()
        } catch {
            print("无法加载音频文件: \(error.localizedDescription)")
        }
    }

    private func playSoundStart() {
        audioPlayerStart?.play()
    }

    private func prepareSoundEnd() {
        guard let soundURL = Bundle.main.url(forResource: "end", withExtension: "mp3") else { return }
        do {
            audioPlayerEnd = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayerEnd?.prepareToPlay()
        } catch {
            print("无法加载音频文件: \(error.localizedDescription)")
        }
    }

    private func playSoundEnd() {
        audioPlayerEnd?.play()
    }
}
