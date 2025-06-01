//
//  EdgeChallengeView.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/9/17.
//

import SwiftUI

struct EdgeChallengeView: View {
    var body: some View {
        NavigationView{
            ZStack{
                Text("🤞")
                    .font(.system(size: 150))
                    .opacity(0.2)
                    .blur(radius: 4)
                
                VStack{
                    Text("🤞边缘挑战")
                        .font(.custom("zixiaohunnaitangti_T", size:20))
                        .padding(.top, 30)
                    
                    Spacer()
                    
                    Text("挤奶十秒休息五秒,你能撑到第几轮？")
                        .font(.custom("zixiaohunnaitangti_T", size:14))
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    NavigationLink(destination: EdgeChallengeView_StartView()){
                        Text("进入挑战")
                            .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                }
            }
        }
    }
}

#Preview {
    EdgeChallengeView()
}
