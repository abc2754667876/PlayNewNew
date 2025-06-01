//
//  ChallengeView.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/9/9.
//

import SwiftUI

struct ChallengeView: View {
    var body: some View {
        NavigationView{
            ZStack{
                Text("✊")
                    .font(.system(size: 150))
                    .opacity(0.2)
                    .blur(radius: 4)
                
                ScrollView{
                    VStack{
                        Text("😶‍🌫️奶桶挑战")
                            .font(.custom("zixiaohunnaitangti_T", size:20))
                            .padding(.bottom)
                            .padding(.top, 30)
                        
                        Divider()
                            .padding(.bottom)
                            .padding(.leading)
                            .padding(.trailing)
                        
                        HStack{
                            Text("✊挑战列表")
                                .font(.custom("zixiaohunnaitangti_T", size:14))
                                .opacity(0.9)
                            Spacer()
                        }
                        .padding(.bottom)
                        NavigationLink(destination: FrequencyChallengeView()){
                            Text("👌频率挑战")
                                .font(.custom("zixiaohunnaitangti_T", size:14))
                        }
                        .padding(.bottom)
                        
                        NavigationLink(destination: EdgeChallengeView()){
                            Text("🤞边缘挑战")
                                .font(.custom("zixiaohunnaitangti_T", size:14))
                        }
                        .padding(.bottom)
                        
                        NavigationLink(destination:                         TimeChallengeView_StartView()){
                            Text("⏰时长挑战")
                                .font(.custom("zixiaohunnaitangti_T", size:14))
                        }
                        .padding(.bottom)
                        
                        Text("更多挑战开发中...")
                            .font(.custom("zixiaohunnaitangti_T", size:12))
                            .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                            .padding(.bottom)
                    }
                }

            }
        }
    }
}

#Preview {
    ChallengeView()
}
