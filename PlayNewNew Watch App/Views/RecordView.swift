//
//  RecordView.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/8/18.
//

import SwiftUI
import SwiftUICharts

struct RecordView: View {
    var body: some View {
        ZStack{
            Text("🐮")
                .font(.system(size: 150))
                .opacity(0.2)
                .blur(radius: 4)
            
            TabView{
                OverView()
                DailyView()
                WeeklyView()
                MonthlyView()
            }
            .tabViewStyle(PageTabViewStyle())
        }
    }
}

struct OverView: View{
    @State private var records: [DataRecord] = loadDataRecordsForLastWeek()
    @State private var tapCount = 0
    @State private var navigateToNextView = false
    
    var body: some View{
        if navigateToNextView{
            GoodNewsView(navigateToNextView: $navigateToNextView)
        }
        else{
            VStack{
                if(records.count == 0){
                    Text("🥵急需挤奶")
                        .font(.custom("zixiaohunnaitangti_T", size:20))
                }
                else if(records.count > 0 && records.count <= 3){
                    Text("😋奶质优良")
                        .font(.custom("zixiaohunnaitangti_T", size:20))
                }
                else if(records.count > 3 && records.count <= 7){
                    Text("😶奶质堪忧")
                        .font(.custom("zixiaohunnaitangti_T", size:20))
                }
                else if(records.count > 7){
                    Text("😨精尽牛亡")
                        .font(.custom("zixiaohunnaitangti_T", size:20))
                }
                
                Button(action: {
                    tapCount += 1
                    if tapCount >= 10 {
                        navigateToNextView = true
                        tapCount = 0 // 重置点击计数
                    }
                }) {
                    Text("您本周挤奶" + String(records.count) + "次，注意适当控制挤奶次数，可有效防止奶源枯竭")
                        .font(.custom("zixiaohunnaitangti_T", size:12))
                        .multilineTextAlignment(.center)
                        .padding(.top, 1)
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                }
                .buttonStyle(TransparentButtonStyle())
                
                Spacer()
                
                Text("👉左划查看日报、周报与月报")
                    .font(.custom("zixiaohunnaitangti_T", size:10))
                    .multilineTextAlignment(.center)
                    .padding(.top, 1)
                    .opacity(0.9)
            }
            .padding(.top)
            .padding(.bottom)
            .onAppear{
                records = loadDataRecordsForLastWeek()
            }
        }
    }
}

struct DailyView: View{
    @State private var records: [DataRecord] = loadDataRecordsForToday()
    var body: some View{
        ScrollView{
            VStack{
                Text("☀挤奶日报")
                    .font(.custom("zixiaohunnaitangti_T", size:16))
                
                if(records.isEmpty){
                    Text("您今日未挤奶")
                        .font(.custom("zixiaohunnaitangti_T", size:12))
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        .padding(.top, 1)
                }
                else{
                    Text("您今天挤奶" + String(records.count) + "次")
                        .font(.custom("zixiaohunnaitangti_T", size:12))
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        .padding(.top, 1)
                }
                
                VStack{
                    let spendStats = calculateSpendStatistics(from: records)
                    let countStats = calculateCountStatistics(from: records)
                    let frequencyStats = calculateFrequencyStatistics(from: records)
                    let heartRateStats = calculateHeartRateStatistics(from: records)
                    
                    HStack{
                        Text("⏱最短用时")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(formatTime(spendStats.minSpend))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("⏱最长用时")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(formatTime(spendStats.maxSpend))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("⏱平均用时")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(formatTime(spendStats.averageSpend))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("👋最低次数")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(countStats.minCount))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("👋最高次数")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(countStats.maxCount))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("👋平均次数")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", countStats.averageCount))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("👌最低频率")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", frequencyStats.minFrequency) + "次/秒")                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("👌最高频率")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", frequencyStats.maxFrequency) + "次/秒")                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("👌平均频率")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", frequencyStats.averageFrequency) + "次/秒")                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("💗最低心率")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", heartRateStats.minHeartRate))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("💗最高心率")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", heartRateStats.maxHeartRate))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("💗平均心率")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", heartRateStats.averageHeartRate))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                }
                .padding(.top)
            }
        }
        .padding(.bottom)
        .onAppear{
            records = loadDataRecordsForToday()
        }
    }
}

struct WeeklyView: View{
    @State private var records: [DataRecord] = loadDataRecordsForLastWeek()
    
    var body: some View {
        ScrollView{
            VStack{
                Text("📅挤奶周报")
                    .font(.custom("zixiaohunnaitangti_T", size:16))
                
                if(records.isEmpty){
                    Text("您本周未挤奶")
                        .font(.custom("zixiaohunnaitangti_T", size:12))
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        .padding(.top, 1)
                }
                else{
                    Text("您本周挤奶" + String(records.count) + "次")
                        .font(.custom("zixiaohunnaitangti_T", size:12))
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        .padding(.top, 1)
                }
                
                VStack{
                    let spendStats = calculateSpendStatistics(from: records)
                    let countStats = calculateCountStatistics(from: records)
                    let frequencyStats = calculateFrequencyStatistics(from: records)
                    let heartRateStats = calculateHeartRateStatistics(from: records)
                    
                    HStack{
                        Text("⏱最短用时")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(formatTime(spendStats.minSpend))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("⏱最长用时")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(formatTime(spendStats.maxSpend))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("⏱平均用时")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(formatTime(spendStats.averageSpend))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("👋最低次数")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(countStats.minCount))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("👋最高次数")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(countStats.maxCount))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("👋平均次数")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", countStats.averageCount))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("👌最低频率")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", frequencyStats.minFrequency) + "次/秒")                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("👌最高频率")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", frequencyStats.maxFrequency) + "次/秒")                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("👌平均频率")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", frequencyStats.averageFrequency) + "次/秒")                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("💗最低心率")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", heartRateStats.minHeartRate))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("💗最高心率")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", heartRateStats.maxHeartRate))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("💗平均心率")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", heartRateStats.averageHeartRate))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                }
                .padding(.top)
                
                let dataByDay = organizeDataByDay(from: records)
                let dailyAverages = calculateDailyAverages(from: dataByDay)
                ForEach(dailyAverages, id: \.date) { average in
                    VStack{
                        Divider()
                            .padding()
                        
                        RecordView_InfoCard(
                            date: formatDate(average.date),
                            numberOFtimes: "\(dataByDay[average.date]?.count ?? 0)",
                            spend: formatTime(Int(average.spend)),
                            count: String(format: "%.1f", average.count),
                            frequency: String(format: "%.1f", average.frequency),
                            heartRate: String(format: "%.1f", average.heartRate)
                        )
                    }
                }
            }
        }
    }
}

struct MonthlyView: View{
    @State private var records: [DataRecord] = loadDataRecordsForLastMonth()
    
    var body: some View {
        ScrollView{
            VStack{
                Text("🌙挤奶月报")
                    .font(.custom("zixiaohunnaitangti_T", size:16))
                
                if(records.isEmpty){
                    Text("您本月未挤奶")
                        .font(.custom("zixiaohunnaitangti_T", size:12))
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        .padding(.top, 1)
                }
                else{
                    Text("您本月挤奶" + String(records.count) + "次")
                        .font(.custom("zixiaohunnaitangti_T", size:12))
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        .padding(.top, 1)
                }
                
                VStack{
                    let spendStats = calculateSpendStatistics(from: records)
                    let countStats = calculateCountStatistics(from: records)
                    let frequencyStats = calculateFrequencyStatistics(from: records)
                    let heartRateStats = calculateHeartRateStatistics(from: records)
                    
                    HStack{
                        Text("⏱最短用时")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(formatTime(spendStats.minSpend))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("⏱最长用时")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(formatTime(spendStats.maxSpend))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("⏱平均用时")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(formatTime(spendStats.averageSpend))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("👋最低次数")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(countStats.minCount))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("👋最高次数")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(countStats.maxCount))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("👋平均次数")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", countStats.averageCount))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("👌最低频率")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", frequencyStats.minFrequency) + "次/秒")                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("👌最高频率")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", frequencyStats.maxFrequency) + "次/秒")                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("👌平均频率")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", frequencyStats.averageFrequency) + "次/秒")                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("💗最低心率")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", heartRateStats.minHeartRate))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("💗最高心率")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", heartRateStats.maxHeartRate))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    
                    HStack{
                        Text("💗平均心率")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(0.9)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", heartRateStats.averageHeartRate))                        .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                }
                .padding(.top)
                
                let dataByDay = organizeDataByDay(from: records)
                let dailyAverages = calculateDailyAverages(from: dataByDay)
                ForEach(dailyAverages, id: \.date) { average in
                    VStack{
                        Divider()
                            .padding()
                        
                        RecordView_InfoCard(
                            date: formatDate(average.date),
                            numberOFtimes: "\(dataByDay[average.date]?.count ?? 0)",
                            spend: formatTime(Int(average.spend)),
                            count: String(format: "%.1f", average.count),
                            frequency: String(format: "%.1f", average.frequency),
                            heartRate: String(format: "%.1f", average.heartRate)
                        )
                    }
                }
            }
        }
    }
}

struct TransparentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color.clear) // 背景颜色透明
            .padding() // 根据需要添加或调整内边距
    }
}

private func formatTime(_ seconds: Int) -> String {
    let minutes = seconds / 60
    let seconds = seconds % 60
    return String(format: "%02d:%02d", minutes, seconds)
}

private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter.string(from: date)
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    RecordView()
}
