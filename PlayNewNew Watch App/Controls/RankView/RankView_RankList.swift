//
//  RankView_RankList.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/8/28.
//

import SwiftUI

struct RankView_RankList: View {
    var position: String
    var userName: String
    var data: String
    
    var body: some View {
        HStack{
            HStack{
                Text(position)
                    .font(.custom("zixiaohunnaitangti_T", size:14))
                    .padding(.trailing, 5)
                Text(userName)
                    .font(.custom("zixiaohunnaitangti_T", size:14))
                    .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
            }
            
            Spacer()
            
            Text(data)
                .font(.custom("zixiaohunnaitangti_T", size:15))
        }
        .padding(.top, 2)
        .padding(.bottom, 2)
    }
}

#Preview {
    RankView_RankList(position: "1", userName: "牛小勇", data: "20")
}
