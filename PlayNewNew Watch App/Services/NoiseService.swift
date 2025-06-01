//
//  NoiseService.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/8/27.
//

import Foundation
import AVFoundation

class NoiseDetector: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    @Published var noiseLevel: Int = 0
    
    func startMonitoring() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let settings: [String: Any] = [
                AVFormatIDKey: kAudioFormatAppleLossless,
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
            ]
            
            let tempDir = NSTemporaryDirectory()
            let filePath = tempDir + "/temp.caf"
            let url = URL(fileURLWithPath: filePath)
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.audioRecorder?.updateMeters()
                if let averagePower = self.audioRecorder?.averagePower(forChannel: 0) {
                    self.noiseLevel = 100 + Int(averagePower)
                }
            }
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func stopMonitoring() {
        audioRecorder?.stop()
        audioRecorder = nil
    }
}
