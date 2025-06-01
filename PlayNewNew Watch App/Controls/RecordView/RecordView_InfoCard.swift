//
//  RecordView_InfoCard.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/8/20.
//

import SwiftUI

struct RecordView_InfoCard: View {
    var date: String
    var numberOFtimes: String
    var spend: String
    var count: String
    var frequency: String
    var heartRate: String
    
    var body: some View {
        VStack{
            HStack{
                Text(date + " · ")
                    .font(.custom("zixiaohunnaitangti_T", size:16))
                Text("挤奶" + numberOFtimes + "次")
                    .font(.custom("zixiaohunnaitangti_T", size:16))
                    .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                Spacer()
            }
            .padding(.bottom, 5)
            
            HStack{
                Text("⏱平均用时")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                    .opacity(0.9)
                
                Spacer()
                
                Text(spend)                        .font(.custom("zixiaohunnaitangti_T", size:14))
            }
            .padding(.bottom, 1)
            
            HStack{
                Text("👋平均次数")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                    .opacity(0.9)
                
                Spacer()
                
                Text(count + "次")                        .font(.custom("zixiaohunnaitangti_T", size:14))
            }
            .padding(.bottom, 1)
            
            HStack{
                Text("👌平均频率")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                    .opacity(0.9)
                
                Spacer()
                
                Text(frequency + "次/秒")                        .font(.custom("zixiaohunnaitangti_T", size:14))
            }
            .padding(.bottom, 1)
            
            HStack{
                Text("💗平均心率")                        .font(.custom("zixiaohunnaitangti_T", size:12))
                    .opacity(0.9)
                
                Spacer()
                
                Text(heartRate)                        .font(.custom("zixiaohunnaitangti_T", size:14))
            }
            .padding(.bottom, 1)
        }
        .frame(width: .infinity, height: .infinity)
        .padding(.bottom, 15)
    }
}

#Preview {
    RecordView_InfoCard(date: "7月6日", numberOFtimes: "6", spend: "00:32", count: "23", frequency: "34.8", heartRate: "89.0")
}
