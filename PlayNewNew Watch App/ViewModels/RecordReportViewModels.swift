//
//  RecordReportViewModels.swift
//  PlayNewNew Watch App
//

import Foundation

enum RecordReportDisplay {
    static func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct DailyAverageCardItem: Identifiable {
    let id: Date
    let formattedDate: String
    let timesPerDay: String
    let spend: String
    let count: String
    let frequency: String
    let heartRate: String
}

final class RecordOverviewViewModel: ObservableObject {
    @Published var records: [DataRecord] = []
    @Published var tapCount = 0
    @Published var navigateToNextView = false

    var headlineText: String {
        let c = records.count
        if c == 0 { return "🥵急需挤奶" }
        if c <= 3 { return "😋奶质优良" }
        if c <= 7 { return "😶奶质堪忧" }
        return "😨精尽牛亡"
    }

    func refresh() {
        records = loadDataRecordsForLastWeek()
    }

    func onSummaryTap() {
        tapCount += 1
        if tapCount >= 10 {
            navigateToNextView = true
            tapCount = 0
        }
    }
}

final class RecordDailyViewModel: ObservableObject {
    @Published var records: [DataRecord] = []

    var spendStats: (maxSpend: Int, minSpend: Int, averageSpend: Int) {
        calculateSpendStatistics(from: records)
    }
    var countStats: (maxCount: Int, minCount: Int, averageCount: Int) {
        calculateCountStatistics(from: records)
    }
    var frequencyStats: (maxFrequency: Double, minFrequency: Double, averageFrequency: Double) {
        calculateFrequencyStatistics(from: records)
    }
    var heartRateStats: (maxHeartRate: Double, minHeartRate: Double, averageHeartRate: Double) {
        calculateHeartRateStatistics(from: records)
    }

    func refresh() {
        records = loadDataRecordsForToday()
    }
}

final class RecordWeeklyViewModel: ObservableObject {
    @Published var records: [DataRecord] = []

    var spendStats: (maxSpend: Int, minSpend: Int, averageSpend: Int) {
        calculateSpendStatistics(from: records)
    }
    var countStats: (maxCount: Int, minCount: Int, averageCount: Int) {
        calculateCountStatistics(from: records)
    }
    var frequencyStats: (maxFrequency: Double, minFrequency: Double, averageFrequency: Double) {
        calculateFrequencyStatistics(from: records)
    }
    var heartRateStats: (maxHeartRate: Double, minHeartRate: Double, averageHeartRate: Double) {
        calculateHeartRateStatistics(from: records)
    }

    var dailyCardItems: [DailyAverageCardItem] {
        let dataByDay = organizeDataByDay(from: records)
        let dailyAverages = calculateDailyAverages(from: dataByDay)
        return dailyAverages.map { average in
            DailyAverageCardItem(
                id: average.date,
                formattedDate: RecordReportDisplay.formatDate(average.date),
                timesPerDay: "\(dataByDay[average.date]?.count ?? 0)",
                spend: RecordReportDisplay.formatTime(Int(average.spend)),
                count: String(format: "%.1f", average.count),
                frequency: String(format: "%.1f", average.frequency),
                heartRate: String(format: "%.1f", average.heartRate)
            )
        }
    }

    func refresh() {
        records = loadDataRecordsForLastWeek()
    }
}

final class RecordMonthlyViewModel: ObservableObject {
    @Published var records: [DataRecord] = []

    var spendStats: (maxSpend: Int, minSpend: Int, averageSpend: Int) {
        calculateSpendStatistics(from: records)
    }
    var countStats: (maxCount: Int, minCount: Int, averageCount: Int) {
        calculateCountStatistics(from: records)
    }
    var frequencyStats: (maxFrequency: Double, minFrequency: Double, averageFrequency: Double) {
        calculateFrequencyStatistics(from: records)
    }
    var heartRateStats: (maxHeartRate: Double, minHeartRate: Double, averageHeartRate: Double) {
        calculateHeartRateStatistics(from: records)
    }

    var dailyCardItems: [DailyAverageCardItem] {
        let dataByDay = organizeDataByDay(from: records)
        let dailyAverages = calculateDailyAverages(from: dataByDay)
        return dailyAverages.map { average in
            DailyAverageCardItem(
                id: average.date,
                formattedDate: RecordReportDisplay.formatDate(average.date),
                timesPerDay: "\(dataByDay[average.date]?.count ?? 0)",
                spend: RecordReportDisplay.formatTime(Int(average.spend)),
                count: String(format: "%.1f", average.count),
                frequency: String(format: "%.1f", average.frequency),
                heartRate: String(format: "%.1f", average.heartRate)
            )
        }
    }

    func refresh() {
        records = loadDataRecordsForLastMonth()
    }
}
