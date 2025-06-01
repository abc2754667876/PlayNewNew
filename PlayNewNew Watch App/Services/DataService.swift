//
//  DataService.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/8/18.
//

import Foundation

struct DataRecord: Codable {
    let date: Date
    let spend: Int
    let count: Int
    let frequency: Double
    let heartRate: Double
}

func saveDataRecord(_ record: DataRecord) {
    var records = loadDataRecords()
    records.append(record)
    
    if let encodedData = try? JSONEncoder().encode(records) {
        UserDefaults.standard.set(encodedData, forKey: "dataRecords")
    }
}

//读出所有数据
func loadDataRecords() -> [DataRecord] {
    if let savedData = UserDefaults.standard.data(forKey: "dataRecords") {
        if let decodedRecords = try? JSONDecoder().decode([DataRecord].self, from: savedData) {
            return decodedRecords
        }
    }
    return []
}

//读出近七天的数据
func loadDataRecordsForLastWeek() -> [DataRecord] {
    let allRecords = loadDataRecords()
    let calendar = Calendar.current
    let now = Date()
    let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now)!
    
    return allRecords.filter { record in
        return record.date >= sevenDaysAgo && record.date <= now
    }
}

//读出近一个月（30天的数据）
func loadDataRecordsForLastMonth() -> [DataRecord] {
    let allRecords = loadDataRecords()
    let calendar = Calendar.current
    let now = Date()
    let sevenDaysAgo = calendar.date(byAdding: .day, value: -30, to: now)!
    
    return allRecords.filter { record in
        return record.date >= sevenDaysAgo && record.date <= now
    }
}

//读出当天的数据
func loadDataRecordsForToday() -> [DataRecord] {
    let allRecords = loadDataRecords()
    let calendar = Calendar.current
    let now = Date()
    let startOfDay = calendar.startOfDay(for: now)
    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

    return allRecords.filter { record in
        return record.date >= startOfDay && record.date < endOfDay
    }
}

//获取spend的最大值、最小值和平均值
func calculateSpendStatistics(from records: [DataRecord]) -> (maxSpend: Int, minSpend: Int, averageSpend: Int) {
    guard !records.isEmpty else {
        // Return default values if there are no records
        return (maxSpend: 0, minSpend: 0, averageSpend: 0)
    }
    
    // Extract all spend values
    let spends = records.map { $0.spend }
    
    // Calculate maximum spend
    let maxSpend = spends.max() ?? 0
    
    // Calculate minimum spend
    let minSpend = spends.min() ?? 0
    
    // Calculate average spend
    let totalSpend = spends.reduce(0, +)
    let averageSpend = Int(Double(totalSpend) / Double(spends.count))
    
    return (maxSpend, minSpend, averageSpend)
}

//获取count的最大值、最小值和平均值
func calculateCountStatistics(from records: [DataRecord]) -> (maxCount: Int, minCount: Int, averageCount: Int) {
    guard !records.isEmpty else {
        // Return default values if there are no records
        return (maxCount: 0, minCount: 0, averageCount: 0)
    }
    
    // Extract all spend values
    let counts = records.map { $0.count }
    
    // Calculate maximum spend
    let maxCount = counts.max() ?? 0
    
    // Calculate minimum spend
    let minCount = counts.min() ?? 0
    
    // Calculate average spend
    let totalCount = counts.reduce(0, +)
    let averageCount = Int(Double(totalCount) / Double(counts.count))
    
    return (maxCount, minCount, averageCount)
}

//获取frequency的最大值、最小值和平均值
func calculateFrequencyStatistics(from records: [DataRecord]) -> (maxFrequency: Double, minFrequency: Double, averageFrequency: Double) {
    guard !records.isEmpty else {
        // Return default values if there are no records
        return (maxFrequency: 0, minFrequency: 0, averageFrequency: 0.0)
    }
    
    // Extract all spend values
    let frequencies = records.map { $0.frequency }
    
    // Calculate maximum spend
    let maxFrequency = frequencies.max() ?? 0
    
    // Calculate minimum spend
    let minFrequency = frequencies.min() ?? 0
    
    // Calculate average spend
    let totalFrequency = frequencies.reduce(0, +)
    let averageFrequency = Double(totalFrequency) / Double(frequencies.count)
    
    return (maxFrequency, minFrequency, averageFrequency)
}

//获取heartRate的最大值、最小值和平均值
func calculateHeartRateStatistics(from records: [DataRecord]) -> (maxHeartRate: Double, minHeartRate: Double, averageHeartRate: Double) {
    guard !records.isEmpty else {
        // Return default values if there are no records
        return (maxHeartRate: 0, minHeartRate: 0, averageHeartRate: 0.0)
    }
    
    // Extract all spend values
    let heartRates = records.map { $0.heartRate }
    
    // Calculate maximum spend
    let maxHeartRate = heartRates.max() ?? 0
    
    // Calculate minimum spend
    let minHeartRate = heartRates.min() ?? 0
    
    // Calculate average spend
    let totalHeartRate = heartRates.reduce(0, +)
    let averageHeartRate = Double(totalHeartRate) / Double(heartRates.count)
    
    return (maxHeartRate, minHeartRate, averageHeartRate)
}

func organizeDataByDay(from records: [DataRecord]) -> [Date: [DataRecord]] {
    let calendar = Calendar.current
    var dataByDay: [Date: [DataRecord]] = [:]
    
    for record in records {
        let day = calendar.startOfDay(for: record.date)
        if dataByDay[day] == nil {
            dataByDay[day] = []
        }
        dataByDay[day]?.append(record)
    }
    
    return dataByDay
}

func calculateDailyAverages(from dataByDay: [Date: [DataRecord]]) -> [(date: Date, spend: Double, count: Double, frequency: Double, heartRate: Double)] {
    let sortedDates = dataByDay.keys.sorted()
    
    return sortedDates.map { date in
        let records = dataByDay[date]!
        let spendSum = records.map { $0.spend }.reduce(0, +)
        let countSum = records.map { $0.count }.reduce(0, +)
        let frequencySum = records.map { $0.frequency }.reduce(0, +)
        let heartRateSum = records.map { $0.heartRate }.reduce(0, +)
        
        let spendAvg = records.isEmpty ? 0 : Double(spendSum) / Double(records.count)
        let countAvg = records.isEmpty ? 0 : Double(countSum) / Double(records.count)
        let frequencyAvg = records.isEmpty ? 0 : frequencySum / Double(records.count)
        let heartRateAvg = records.isEmpty ? 0 : heartRateSum / Double(records.count)
        
        return (date: date, spend: spendAvg, count: countAvg, frequency: frequencyAvg, heartRate: heartRateAvg)
    }
}

func clearDataRecords() {
    UserDefaults.standard.removeObject(forKey: "dataRecords")
}
