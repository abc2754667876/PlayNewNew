//
//  ShakeDetectionService.swift
//  PlayNewNew Watch App
//

import CoreMotion
import Foundation
import simd

struct ShakeDetectionConfiguration {
    struct Keys {
        static let peakThreshold = "shakePeakThreshold"
        static let resetThreshold = "shakeResetThreshold"
        static let minimumPeakInterval = "shakeMinimumPeakInterval"
        static let smoothingFactor = "shakeSmoothingFactor"
        static let directionConfidenceThreshold = "shakeDirectionConfidenceThreshold"
        static let legacyAccelerationThreshold = "accelerationThreshold"
        static let legacyTimeThreshold = "timeThreshold"
    }

    static let defaultValue = ShakeDetectionConfiguration(
        peakThreshold: 0.85,
        resetThreshold: 0.22,
        minimumPeakInterval: 0.22,
        smoothingFactor: 0.18,
        directionConfidenceThreshold: 0.55,
        directionAdaptation: 0.18,
        inactivityResetInterval: 1.0,
        sampleInterval: 1.0 / 50.0
    )

    var peakThreshold: Double
    var resetThreshold: Double
    var minimumPeakInterval: TimeInterval
    var smoothingFactor: Double
    var directionConfidenceThreshold: Double
    var directionAdaptation: Double
    var inactivityResetInterval: TimeInterval
    var sampleInterval: TimeInterval

    static func load(from defaults: UserDefaults = .standard) -> ShakeDetectionConfiguration {
        let legacyPeak = defaults.object(forKey: Keys.legacyAccelerationThreshold) as? Double
        let legacyInterval = defaults.object(forKey: Keys.legacyTimeThreshold) as? Double
        let base = defaultValue

        return ShakeDetectionConfiguration(
            peakThreshold: readDouble(Keys.peakThreshold, defaults: defaults) ?? legacyPeak ?? base.peakThreshold,
            resetThreshold: readDouble(Keys.resetThreshold, defaults: defaults) ?? base.resetThreshold,
            minimumPeakInterval: readDouble(Keys.minimumPeakInterval, defaults: defaults) ?? legacyInterval ?? base.minimumPeakInterval,
            smoothingFactor: readDouble(Keys.smoothingFactor, defaults: defaults) ?? base.smoothingFactor,
            directionConfidenceThreshold: readDouble(Keys.directionConfidenceThreshold, defaults: defaults) ?? base.directionConfidenceThreshold,
            directionAdaptation: base.directionAdaptation,
            inactivityResetInterval: base.inactivityResetInterval,
            sampleInterval: base.sampleInterval
        )
    }

    func persist(to defaults: UserDefaults = .standard) {
        defaults.set(peakThreshold, forKey: Keys.peakThreshold)
        defaults.set(resetThreshold, forKey: Keys.resetThreshold)
        defaults.set(minimumPeakInterval, forKey: Keys.minimumPeakInterval)
        defaults.set(smoothingFactor, forKey: Keys.smoothingFactor)
        defaults.set(directionConfidenceThreshold, forKey: Keys.directionConfidenceThreshold)

        // Keep legacy keys in sync so older code paths and existing installs stay usable.
        defaults.set(peakThreshold, forKey: Keys.legacyAccelerationThreshold)
        defaults.set(minimumPeakInterval, forKey: Keys.legacyTimeThreshold)
    }

    static func reset(in defaults: UserDefaults = .standard) {
        defaultValue.persist(to: defaults)
    }

    private static func readDouble(_ key: String, defaults: UserDefaults) -> Double? {
        defaults.object(forKey: key) as? Double
    }
}

struct ShakeDetectionEvent {
    let count: Int
    let timestamp: Date
    let dominantAxis: SIMD3<Double>
    let signedProjection: Double
    let filteredMagnitude: Double
}

struct ShakeDetectionDebugSnapshot {
    let rawX: Double
    let rawY: Double
    let rawZ: Double
    let dominantAxisX: Double
    let dominantAxisY: Double
    let dominantAxisZ: Double
    let filteredMagnitude: Double
    let signedProjection: Double
    let directionConfidence: Double
    let stateDescription: String
    let count: Int
}

final class ShakeDetectionService {
    private enum DetectorState {
        case waitingForPeak
        case waitingForReset

        var description: String {
            switch self {
            case .waitingForPeak:
                return "等待峰值"
            case .waitingForReset:
                return "等待回摆复位"
            }
        }
    }

    private let motionManager = CMMotionManager()

    private var configuration = ShakeDetectionConfiguration.defaultValue
    private var onShake: ((ShakeDetectionEvent) -> Void)?
    private var onDebug: ((ShakeDetectionDebugSnapshot) -> Void)?
    private var shouldCountShake: (() -> Bool)?

    private var filteredVector = SIMD3<Double>(repeating: 0)
    private var dominantAxis = SIMD3<Double>(0, 0, 1)
    private var hasLockedAxis = false
    private var countingSign = 0.0
    private var state: DetectorState = .waitingForPeak
    private var count = 0
    private var lastAcceptedMotionTimestamp: TimeInterval?

    func start(
        configuration: ShakeDetectionConfiguration = .load(),
        shouldCountShake: (() -> Bool)? = nil,
        onShake: @escaping (ShakeDetectionEvent) -> Void,
        onDebug: ((ShakeDetectionDebugSnapshot) -> Void)? = nil
    ) {
        stop(resetCount: true)

        guard motionManager.isDeviceMotionAvailable else { return }

        self.configuration = configuration
        self.onShake = onShake
        self.onDebug = onDebug
        self.shouldCountShake = shouldCountShake

        motionManager.deviceMotionUpdateInterval = configuration.sampleInterval
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let motion else { return }
            self.handle(motion: motion)
        }
    }

    func stop(resetCount: Bool = true) {
        motionManager.stopDeviceMotionUpdates()
        onShake = nil
        onDebug = nil
        shouldCountShake = nil

        filteredVector = SIMD3<Double>(repeating: 0)
        dominantAxis = SIMD3<Double>(0, 0, 1)
        hasLockedAxis = false
        countingSign = 0
        state = .waitingForPeak
        lastAcceptedMotionTimestamp = nil

        if resetCount {
            count = 0
        }
    }

    func resetCycle() {
        filteredVector = SIMD3<Double>(repeating: 0)
        dominantAxis = SIMD3<Double>(0, 0, 1)
        hasLockedAxis = false
        countingSign = 0
        state = .waitingForPeak
        lastAcceptedMotionTimestamp = nil
    }

    private func handle(motion: CMDeviceMotion) {
        let raw = SIMD3<Double>(
            motion.userAcceleration.x,
            motion.userAcceleration.y,
            motion.userAcceleration.z
        )
        let alpha = configuration.smoothingFactor
        filteredVector = filteredVector * (1.0 - alpha) + raw * alpha

        let magnitude = simd_length(filteredVector)
        if magnitude >= configuration.resetThreshold {
            updateDominantAxis(using: filteredVector)
        }

        if let lastAcceptedMotionTimestamp,
           motion.timestamp - lastAcceptedMotionTimestamp > configuration.inactivityResetInterval {
            resetCycle()
        }

        let projection = hasLockedAxis ? simd_dot(filteredVector, dominantAxis) : magnitude
        let effectiveSign = currentCountingSign(for: projection)
        let alignedProjection = projection * effectiveSign
        let directionConfidence = magnitude > 0.0001 ? min(1.0, abs(projection) / magnitude) : 0
        let canUseCurrentDirection = directionConfidence >= configuration.directionConfidenceThreshold

        if countingSign == 0,
           abs(projection) >= configuration.peakThreshold * 0.7,
           canUseCurrentDirection {
            countingSign = projection >= 0 ? 1 : -1
        }

        switch state {
        case .waitingForPeak:
            tryAcceptPeak(
                alignedProjection: alignedProjection,
                magnitude: magnitude,
                directionConfidence: directionConfidence,
                motionTimestamp: motion.timestamp
            )
        case .waitingForReset:
            if alignedProjection <= configuration.resetThreshold || abs(projection) <= configuration.resetThreshold {
                state = .waitingForPeak
            }
        }

        onDebug?(
            ShakeDetectionDebugSnapshot(
                rawX: raw.x,
                rawY: raw.y,
                rawZ: raw.z,
                dominantAxisX: dominantAxis.x,
                dominantAxisY: dominantAxis.y,
                dominantAxisZ: dominantAxis.z,
                filteredMagnitude: magnitude,
                signedProjection: alignedProjection,
                directionConfidence: directionConfidence,
                stateDescription: state.description,
                count: count
            )
        )
    }

    private func tryAcceptPeak(
        alignedProjection: Double,
        magnitude: Double,
        directionConfidence: Double,
        motionTimestamp: TimeInterval
    ) {
        guard alignedProjection >= configuration.peakThreshold else { return }
        guard magnitude >= configuration.peakThreshold else { return }
        guard directionConfidence >= configuration.directionConfidenceThreshold else { return }

        if let lastAcceptedMotionTimestamp,
           motionTimestamp - lastAcceptedMotionTimestamp < configuration.minimumPeakInterval {
            return
        }

        guard shouldCountShake?() ?? true else { return }

        count += 1
        lastAcceptedMotionTimestamp = motionTimestamp
        state = .waitingForReset

        onShake?(
            ShakeDetectionEvent(
                count: count,
                timestamp: Date(),
                dominantAxis: dominantAxis,
                signedProjection: alignedProjection,
                filteredMagnitude: magnitude
            )
        )
    }

    private func currentCountingSign(for projection: Double) -> Double {
        if countingSign != 0 {
            return countingSign
        }

        return projection >= 0 ? 1 : -1
    }

    private func updateDominantAxis(using vector: SIMD3<Double>) {
        let magnitude = simd_length(vector)
        guard magnitude > 0.0001 else { return }

        var normalizedVector = vector / magnitude
        if hasLockedAxis, simd_dot(normalizedVector, dominantAxis) < 0 {
            normalizedVector *= -1
        }

        if !hasLockedAxis {
            dominantAxis = normalizedVector
            hasLockedAxis = true
            return
        }

        let adaptation = configuration.directionAdaptation
        let blended = dominantAxis * (1.0 - adaptation) + normalizedVector * adaptation
        let blendedMagnitude = simd_length(blended)
        if blendedMagnitude > 0.0001 {
            dominantAxis = blended / blendedMagnitude
        }
    }
}
