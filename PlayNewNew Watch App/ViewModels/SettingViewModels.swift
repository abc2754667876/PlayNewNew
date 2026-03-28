//
//  SettingViewModels.swift
//  PlayNewNew Watch App
//

import Foundation

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
    @Published var dominantAxisText = "-"
    @Published var filteredMagnitude = 0.0
    @Published var signedProjection = 0.0
    @Published var directionConfidence = 0.0
    @Published var detectorState = "等待峰值"

    private let shakeDetectionService = ShakeDetectionService()

    func resetToDefaults() {
        ShakeDetectionConfiguration.reset()
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
    }

    private func startMotion() {
        isStart = true
        shakeCount = 0
        shakeDetectionService.start(
            configuration: .load(),
            onShake: { [weak self] event in
                self?.shakeCount = event.count
            },
            onDebug: { [weak self] snapshot in
                guard let self else { return }

                self.x = snapshot.rawX
                self.y = snapshot.rawY
                self.z = snapshot.rawZ
                self.filteredMagnitude = snapshot.filteredMagnitude
                self.signedProjection = snapshot.signedProjection
                self.directionConfidence = snapshot.directionConfidence
                self.detectorState = snapshot.stateDescription
                self.dominantAxisText = String(
                    format: "(%.2f, %.2f, %.2f)",
                    snapshot.dominantAxisX,
                    snapshot.dominantAxisY,
                    snapshot.dominantAxisZ
                )
            }
        )
    }

    private func stopMotion() {
        isStart = false
        shakeCount = 0
        shakeDetectionService.stop()
    }
}
