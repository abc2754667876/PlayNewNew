//
//  ChallengeViewModels.swift
//  PlayNewNew Watch App
//

import SwiftUI
import AVFoundation
import WatchKit

// MARK: - Frequency picker & haptic preview

final class FrequencyChallengeViewModel: ObservableObject {
    @Published var selectedNumber = 1
    @Published var isVibrating = false
    @Published var buttonText = "感受频率"

    let numbers = Array(1...30)
    private var timer: Timer?

    func toggleVibration() {
        if isVibrating {
            buttonText = "感受频率"
            stopVibration()
        } else {
            buttonText = "停止感受"
            startVibration()
        }
    }

    func onDisappear() {
        stopVibration()
    }

    private func startVibration() {
        if isVibrating { return }
        isVibrating = true
        let interval = 1.0 / Double(selectedNumber)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            WKInterfaceDevice.current().play(.directionDown)
        }
    }

    private func stopVibration() {
        isVibrating = false
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Countdown (6…1)

final class ChallengeCountdownViewModel: ObservableObject {
    @Published var currentCountdownIndex = 0
    @Published var isAnimating = false

    private let countdownNumbers = ["6", "5", "4", "3", "2", "1"]

    var displayedNumber: String? {
        guard currentCountdownIndex < countdownNumbers.count else { return nil }
        return countdownNumbers[currentCountdownIndex]
    }

    func start(countdownFinished: Binding<Bool>) {
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
            guard let self else { return }
            if self.currentCountdownIndex < self.countdownNumbers.count {
                self.isAnimating = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isAnimating = false
                }
                self.currentCountdownIndex += 1
            } else {
                t.invalidate()
                countdownFinished.wrappedValue = true
            }
        }
        RunLoop.current.add(timer, forMode: .common)
    }
}

// MARK: - Time challenge session

final class TimeChallengeSessionViewModel: ObservableObject {
    @Published var elapsedTime = 0
    @Published var shakeCount = 0
    @Published var isShaking = true

    private let shakeDetectionService = ShakeDetectionService()
    private var timer: Timer?
    private var startTime: Date?
    private var audioPlayerEnd: AVAudioPlayer?

    func onAppear() {
        startShaking()
        if Self.readSoundOpen() {
            prepareSoundEnd()
        }
    }

    func stopChallenge() {
        isShaking = false
        timer?.invalidate()
        timer = nil
        shakeDetectionService.stop()
        playSoundEnd()
    }

    func formattedTime() -> String {
        Self.formatTime(elapsedTime)
    }

    private func startShaking() {
        startTime = Date()
        shakeCount = 0

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self, let startTime = self.startTime else { return }
            self.elapsedTime = Int(Date().timeIntervalSince(startTime))
        }

        shakeDetectionService.start(configuration: .load()) { [weak self] event in
            self?.shakeCount = event.count
        }
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

    private func prepareSoundEnd() {
        guard let url = Bundle.main.url(forResource: "end", withExtension: "mp3") else { return }
        do {
            audioPlayerEnd = try AVAudioPlayer(contentsOf: url)
            audioPlayerEnd?.prepareToPlay()
        } catch {
            print("无法加载音频文件: \(error.localizedDescription)")
        }
    }

    private func playSoundEnd() {
        audioPlayerEnd?.play()
    }
}

// MARK: - Frequency challenge session

final class FrequencyChallengeSessionViewModel: ObservableObject {
    @Published var elapsedTime = 0
    @Published var shakeCount = 0
    @Published var isShaking = true

    private let shakeDetectionService = ShakeDetectionService()
    private var timer: Timer?
    private var startTime: Date?
    private var lastDetectedShakeAt: Date?
    private var vibrateTimer: Timer?
    private var isVibrating = false
    private var audioPlayerEnd: AVAudioPlayer?

    var vibrateFrequency: Int = 1

    func onAppear() {
        lastDetectedShakeAt = Date()
        startShaking()
        startVibration()
        if Self.readSoundOpen() {
            prepareSoundEnd()
        }
    }

    func onDisappear() {
        stopVibration()
    }

    func formattedTime() -> String {
        Self.formatTime(elapsedTime)
    }

    func formattedTimeMinusThree() -> String {
        Self.formatTime(max(0, elapsedTime - 3))
    }

    private func startShaking() {
        startTime = Date()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            if let startTime = self.startTime {
                self.elapsedTime = Int(Date().timeIntervalSince(startTime))
            }
            let now = Date()
            if let lastDetectedShakeAt = self.lastDetectedShakeAt, now.timeIntervalSince(lastDetectedShakeAt) > 4.0 {
                self.stopShaking()
            }
        }

        shakeDetectionService.start(configuration: .load()) { [weak self] event in
            guard let self else { return }
            self.shakeCount = event.count
            self.lastDetectedShakeAt = event.timestamp
        }
    }

    private func stopShaking() {
        stopVibration()
        isShaking = false
        timer?.invalidate()
        timer = nil
        shakeDetectionService.stop()
        playSoundEnd()
    }

    private func startVibration() {
        if isVibrating { return }
        isVibrating = true
        let interval = 1.0 / Double(max(1, vibrateFrequency))
        vibrateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            WKInterfaceDevice.current().play(.directionDown)
        }
    }

    private func stopVibration() {
        isVibrating = false
        vibrateTimer?.invalidate()
        vibrateTimer = nil
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

    private func prepareSoundEnd() {
        guard let url = Bundle.main.url(forResource: "end", withExtension: "mp3") else { return }
        do {
            audioPlayerEnd = try AVAudioPlayer(contentsOf: url)
            audioPlayerEnd?.prepareToPlay()
        } catch {
            print("无法加载音频文件: \(error.localizedDescription)")
        }
    }

    private func playSoundEnd() {
        audioPlayerEnd?.play()
    }
}

// MARK: - Edge challenge session

final class EdgeChallengeSessionViewModel: ObservableObject {
    @Published var statusText = "现在是：挤奶时间"
    @Published var isMilking = true
    @Published var countdown = 10
    @Published var rounds = 1
    @Published var milkingCompleted = false
    @Published var shakeCount = 0

    private var timer: Timer?
    private let shakeDetectionService = ShakeDetectionService()
    private var lastShakeCount = 0
    private var noMilkingTime = 0
    private var audioPlayerEnd: AVAudioPlayer?

    var completedRoundsText: Int {
        max(0, rounds - 1)
    }

    func onAppear() {
        startMilking()
        startMonitorShake()
        if Self.readSoundOpen() {
            prepareSoundEnd()
        }
    }

    private func startMilking() {
        countdown = 10
        statusText = "现在是：挤奶时间"
        lastShakeCount = shakeCount

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.countdown -= 1
            if self.isMilking {
                self.monitorMilkingActivity()
            }
            if self.countdown <= 0 {
                self.switchStatus()
            }
        }
    }

    private func switchStatus() {
        if isMilking {
            statusText = "现在是：休息时间"
            countdown = 5
        } else {
            statusText = "现在是：挤奶时间"
            countdown = 10
            rounds += 1
            noMilkingTime = 0
            lastShakeCount = shakeCount
        }
        isMilking.toggle()
        if isMilking {
            shakeDetectionService.resetCycle()
        }
    }

    private func stopMilking() {
        timer?.invalidate()
        timer = nil
        shakeDetectionService.stop()
        milkingCompleted = true
    }

    private func monitorMilkingActivity() {
        if shakeCount == lastShakeCount {
            noMilkingTime += 1
        } else {
            noMilkingTime = 0
            lastShakeCount = shakeCount
        }
        if noMilkingTime >= 4 {
            stopMilking()
            playSoundEnd()
        }
    }

    private func startMonitorShake() {
        shakeDetectionService.start(
            configuration: .load(),
            shouldCountShake: { [weak self] in
                self?.isMilking ?? false
            },
            onShake: { [weak self] event in
                self?.shakeCount = event.count
            }
        )
    }

    private static func readSoundOpen() -> Bool {
        if UserDefaults.standard.object(forKey: "isSoundOpen") == nil { return true }
        return UserDefaults.standard.bool(forKey: "isSoundOpen")
    }

    private func prepareSoundEnd() {
        guard let url = Bundle.main.url(forResource: "end", withExtension: "mp3") else { return }
        do {
            audioPlayerEnd = try AVAudioPlayer(contentsOf: url)
            audioPlayerEnd?.prepareToPlay()
        } catch {
            print("无法加载音频文件: \(error.localizedDescription)")
        }
    }

    private func playSoundEnd() {
        audioPlayerEnd?.play()
    }
}
