//
//  RecordView.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/8/18.
//

import SwiftUI

struct RecordView: View {
    var body: some View {
        ZStack {
            Text("🐮")
                .font(.system(size: 150))
                .opacity(0.2)
                .blur(radius: 4)

            TabView {
                OverView()
                DailyView()
                WeeklyView()
                MonthlyView()
            }
            .tabViewStyle(PageTabViewStyle())
        }
    }
}

struct OverView: View {
    @StateObject private var viewModel = RecordOverviewViewModel()
    @StateObject private var goodNewsViewModel = GoodNewsViewModel()

    var body: some View {
        if viewModel.navigateToNextView {
            GoodNewsView(viewModel: goodNewsViewModel, navigateToNextView: $viewModel.navigateToNextView)
        } else {
            VStack {
                Text(viewModel.headlineText)
                    .font(.custom("zixiaohunnaitangti_T", size: 20))

                Button(action: { viewModel.onSummaryTap() }) {
                    Text("您本周挤奶" + String(viewModel.records.count) + "次，注意适当控制挤奶次数，可有效防止奶源枯竭")
                        .font(.custom("zixiaohunnaitangti_T", size: 12))
                        .multilineTextAlignment(.center)
                        .padding(.top, 1)
                        .opacity(0.8)
                }
                .buttonStyle(TransparentButtonStyle())

                Spacer()

                Text("👉左划查看日报、周报与月报")
                    .font(.custom("zixiaohunnaitangti_T", size: 10))
                    .multilineTextAlignment(.center)
                    .padding(.top, 1)
                    .opacity(0.9)
            }
            .padding(.top)
            .padding(.bottom)
            .onAppear {
                viewModel.refresh()
            }
        }
    }
}

struct DailyView: View {
    @StateObject private var viewModel = RecordDailyViewModel()

    var body: some View {
        ScrollView {
            VStack {
                Text("☀挤奶日报")
                    .font(.custom("zixiaohunnaitangti_T", size: 16))

                if viewModel.records.isEmpty {
                    Text("您今日未挤奶")
                        .font(.custom("zixiaohunnaitangti_T", size: 12))
                        .opacity(0.8)
                        .padding(.top, 1)
                } else {
                    Text("您今天挤奶" + String(viewModel.records.count) + "次")
                        .font(.custom("zixiaohunnaitangti_T", size: 12))
                        .opacity(0.8)
                        .padding(.top, 1)
                }

                VStack {
                    let spendStats = viewModel.spendStats
                    let countStats = viewModel.countStats
                    let frequencyStats = viewModel.frequencyStats
                    let heartRateStats = viewModel.heartRateStats

                    HStack {
                        Text("⏱最短用时")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(RecordReportDisplay.formatTime(spendStats.minSpend))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("⏱最长用时")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(RecordReportDisplay.formatTime(spendStats.maxSpend))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("⏱平均用时")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(RecordReportDisplay.formatTime(spendStats.averageSpend))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("👋最低次数")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(countStats.minCount))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("👋最高次数")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(countStats.maxCount))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("👋平均次数")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(format: "%.1f", countStats.averageCount))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("👌最低频率")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(format: "%.1f", frequencyStats.minFrequency) + "次/秒")
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("👌最高频率")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(format: "%.1f", frequencyStats.maxFrequency) + "次/秒")
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("👌平均频率")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(format: "%.1f", frequencyStats.averageFrequency) + "次/秒")
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("💗最低心率")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(format: "%.1f", heartRateStats.minHeartRate))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("💗最高心率")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(format: "%.1f", heartRateStats.maxHeartRate))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("💗平均心率")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(format: "%.1f", heartRateStats.averageHeartRate))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)
                }
                .padding(.top)
            }
        }
        .padding(.bottom)
        .onAppear {
            viewModel.refresh()
        }
    }
}

struct WeeklyView: View {
    @StateObject private var viewModel = RecordWeeklyViewModel()

    var body: some View {
        ScrollView {
            VStack {
                Text("📅挤奶周报")
                    .font(.custom("zixiaohunnaitangti_T", size: 16))

                if viewModel.records.isEmpty {
                    Text("您本周未挤奶")
                        .font(.custom("zixiaohunnaitangti_T", size: 12))
                        .opacity(0.8)
                        .padding(.top, 1)
                } else {
                    Text("您本周挤奶" + String(viewModel.records.count) + "次")
                        .font(.custom("zixiaohunnaitangti_T", size: 12))
                        .opacity(0.8)
                        .padding(.top, 1)
                }

                VStack {
                    let spendStats = viewModel.spendStats
                    let countStats = viewModel.countStats
                    let frequencyStats = viewModel.frequencyStats
                    let heartRateStats = viewModel.heartRateStats

                    HStack {
                        Text("⏱最短用时")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(RecordReportDisplay.formatTime(spendStats.minSpend))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("⏱最长用时")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(RecordReportDisplay.formatTime(spendStats.maxSpend))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("⏱平均用时")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(RecordReportDisplay.formatTime(spendStats.averageSpend))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("👋最低次数")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(countStats.minCount))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("👋最高次数")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(countStats.maxCount))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("👋平均次数")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(format: "%.1f", countStats.averageCount))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("👌最低频率")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(format: "%.1f", frequencyStats.minFrequency) + "次/秒")
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("👌最高频率")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(format: "%.1f", frequencyStats.maxFrequency) + "次/秒")
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("👌平均频率")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(format: "%.1f", frequencyStats.averageFrequency) + "次/秒")
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("💗最低心率")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(format: "%.1f", heartRateStats.minHeartRate))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("💗最高心率")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(format: "%.1f", heartRateStats.maxHeartRate))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("💗平均心率")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(format: "%.1f", heartRateStats.averageHeartRate))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)
                }
                .padding(.top)

                ForEach(viewModel.dailyCardItems) { item in
                    VStack {
                        Divider()
                            .padding()

                        RecordView_InfoCard(
                            date: item.formattedDate,
                            numberOFtimes: item.timesPerDay,
                            spend: item.spend,
                            count: item.count,
                            frequency: item.frequency,
                            heartRate: item.heartRate
                        )
                    }
                }
            }
        }
        .onAppear {
            viewModel.refresh()
        }
    }
}

struct MonthlyView: View {
    @StateObject private var viewModel = RecordMonthlyViewModel()

    var body: some View {
        ScrollView {
            VStack {
                Text("🌙挤奶月报")
                    .font(.custom("zixiaohunnaitangti_T", size: 16))

                if viewModel.records.isEmpty {
                    Text("您本月未挤奶")
                        .font(.custom("zixiaohunnaitangti_T", size: 12))
                        .opacity(0.8)
                        .padding(.top, 1)
                } else {
                    Text("您本月挤奶" + String(viewModel.records.count) + "次")
                        .font(.custom("zixiaohunnaitangti_T", size: 12))
                        .opacity(0.8)
                        .padding(.top, 1)
                }

                VStack {
                    let spendStats = viewModel.spendStats
                    let countStats = viewModel.countStats
                    let frequencyStats = viewModel.frequencyStats
                    let heartRateStats = viewModel.heartRateStats

                    HStack {
                        Text("⏱最短用时")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(RecordReportDisplay.formatTime(spendStats.minSpend))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("⏱最长用时")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(RecordReportDisplay.formatTime(spendStats.maxSpend))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("⏱平均用时")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(RecordReportDisplay.formatTime(spendStats.averageSpend))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("👋最低次数")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(countStats.minCount))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("👋最高次数")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(countStats.maxCount))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("👋平均次数")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(format: "%.1f", countStats.averageCount))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("👌最低频率")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(format: "%.1f", frequencyStats.minFrequency) + "次/秒")
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("👌最高频率")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(format: "%.1f", frequencyStats.maxFrequency) + "次/秒")
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("👌平均频率")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(format: "%.1f", frequencyStats.averageFrequency) + "次/秒")
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("💗最低心率")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(format: "%.1f", heartRateStats.minHeartRate))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("💗最高心率")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(format: "%.1f", heartRateStats.maxHeartRate))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)

                    HStack {
                        Text("💗平均心率")
                            .font(.custom("zixiaohunnaitangti_T", size: 12))
                            .opacity(0.9)

                        Spacer()

                        Text(String(format: "%.1f", heartRateStats.averageHeartRate))
                            .font(.custom("zixiaohunnaitangti_T", size: 14))
                    }
                    .padding(.bottom)
                }
                .padding(.top)

                ForEach(viewModel.dailyCardItems) { item in
                    VStack {
                        Divider()
                            .padding()

                        RecordView_InfoCard(
                            date: item.formattedDate,
                            numberOFtimes: item.timesPerDay,
                            spend: item.spend,
                            count: item.count,
                            frequency: item.frequency,
                            heartRate: item.heartRate
                        )
                    }
                }
            }
        }
        .onAppear {
            viewModel.refresh()
        }
    }
}

struct TransparentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color.clear)
            .padding()
    }
}

#Preview {
    RecordView()
}
