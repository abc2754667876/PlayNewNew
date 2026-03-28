//
//  GoodNewsViewModel.swift
//  PlayNewNew Watch App
//

import AVFoundation

final class GoodNewsViewModel: ObservableObject {
    @Published var records: [DataRecord] = []
    @Published var title = ""

    private var audioPlayer: AVAudioPlayer?

    var weekCountText: String {
        "您本周挤奶\(records.count)次"
    }

    func refreshRecords() {
        records = loadDataRecordsForLastWeek()
    }

    func updateTitleForCurrentRecords() {
        let c = records.count
        if c == 0 { title = "挤奶菜鸟" }
        else if c <= 3 { title = "挤奶新手" }
        else if c <= 7 { title = "挤奶大师" }
        else { title = "精尽人亡" }
    }

    func onAppear() {
        refreshRecords()
        updateTitleForCurrentRecords()
        prepareSound()
        playSound()
    }

    private func prepareSound() {
        guard let soundURL = Bundle.main.url(forResource: "bgm_ya", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("无法加载音频文件: \(error.localizedDescription)")
        }
    }

    private func playSound() {
        audioPlayer?.play()
    }
}
