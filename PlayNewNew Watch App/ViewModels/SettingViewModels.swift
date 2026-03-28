//
//  SettingViewModels.swift
//  PlayNewNew Watch App
//

import CoreMotion

final class SettingViewModel: ObservableObject {
    @Published var showAlert = false
    @Published var alertInfo = ""

    var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "未知"
    }

    func clearAllRecords() {
        clearDataRecords()
        alertInfo = "已清除所有挤奶数据"
        showAlert = true
    }
}

final class AccelerationThresholdSettingViewModel: ObservableObject {
    @Published var shakeCount = 0
    @Published var isStart = false
    @Published var x = 0.0
    @Published var y = 0.0
    @Published var z = 0.0

    private let motionManager = CMMotionManager()
    private let workoutManager = WorkoutManager()
    private var lastShakeTime: Date?

    private static func readAccelerationThreshold() -> Double {
        let v = UserDefaults.standard.object(forKey: "accelerationThreshold")
        return (v as? Double) ?? 0.5
    }

    private static func readTimeThreshold() -> Double {
        let v = UserDefaults.standard.object(forKey: "timeThreshold")
        return (v as? Double) ?? 0.34
    }

    func resetToDefaults() {
        UserDefaults.standard.set(0.5, forKey: "accelerationThreshold")
        UserDefaults.standard.set(0.34, forKey: "timeThreshold")
    }

    func toggleTest() {
        if isStart {
            stopMotion()
        } else {
            startMotion()
        }
    }

    func onDisappear() {
        stopMotion()
        workoutManager.endWorkout()
    }

    private func startMotion() {
        isStart = true
        workoutManager.startWorkout()
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] motion, _ in
            guard let self, let motion else { return }
            let acceleration = motion.userAcceleration
            let threshold = Self.readAccelerationThreshold()
            let now = Date()
            let timeThresh = Self.readTimeThreshold()

            self.x = acceleration.x
            self.y = acceleration.y
            self.z = acceleration.z

            if (acceleration.z > threshold || acceleration.z < -threshold)
                || (acceleration.y > threshold || acceleration.y < -threshold)
                || (acceleration.x > threshold || acceleration.x < -threshold) {
                if let last = self.lastShakeTime, now.timeIntervalSince(last) < timeThresh {
                    return
                }
                if self.isStart {
                    self.shakeCount += 1
                }
                self.lastShakeTime = now
            }
        }
    }

    private func stopMotion() {
        isStart = false
        workoutManager.endWorkout()
        shakeCount = 0
        motionManager.stopDeviceMotionUpdates()
    }
}
