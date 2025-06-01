//
//  ContentView.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/8/12.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView{
            ScrollView{
                VStack {
                    HStack{
                        Text("牛牛挤奶🐮")
                            .bold()
                            .font(.custom("zixiaohunnaitangti_T", size:16))
                        Spacer()
                    }
                    
                    VStack(spacing: 10){
                        NavigationLink(destination: PlayView()){
                            HStack{
                                Text("🥵 开始挤奶")
                                    .font(.custom("zixiaohunnaitangti_T", size:14))
                                Spacer()
                            }
                            .padding(.leading)
                        }
                        
                        NavigationLink(destination: RecordView()){
                            HStack{
                                Text("😍 挤奶记录")
                                    .font(.custom("zixiaohunnaitangti_T", size:14))
                                Spacer()
                            }
                            .padding(.leading)
                        }
                        
                        NavigationLink(destination: ChallengeView()){
                            HStack{
                                Text("😶‍🌫️ 奶桶挑战")
                                    .font(.custom("zixiaohunnaitangti_T", size:14))
                                Spacer()
                            }
                            .padding(.leading)
                        }
                        
                        if GlobalData.shared.accessRank{
                            NavigationLink(destination: RankView()){
                                HStack{
                                    Text("🤯 挤奶排行")
                                        .font(.custom("zixiaohunnaitangti_T", size:14))
                                    Spacer()
                                }
                                .padding(.leading)
                            }
                        }
   
                        NavigationLink(destination: SettingView()){
                            HStack{
                                Text("🤫 挤奶设置")
                                    .font(.custom("zixiaohunnaitangti_T", size:14))
                                Spacer()
                            }
                            .padding(.leading)
                        }
                    }
                    .padding(.top)
                    
                    Text("ICP备案号：\n津ICP备2024023421号-1A")
                        .font(.system(size: 12))
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                }
                .padding(1)
            }
        }
    }
}

#Preview {
    ContentView()
}
