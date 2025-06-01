//
//  GoodNewsView.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/9/18.
//

import SwiftUI
import AVFoundation

struct GoodNewsView: View {
    @State private var audioPlayer: AVAudioPlayer?
    @State private var records: [DataRecord] = loadDataRecordsForLastWeek()
    
    @State private var title = ""
    
    @Binding var navigateToNextView: Bool
    
    var body: some View {
        ZStack{
            GeometryReader { geometry in
                Image("background")
                    .resizable()
                    //.scaledToFill() // 也可以使用 .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    //.clipped() // 如果使用 .scaledToFill()，建议裁剪图片的超出部分
            }
            .edgesIgnoringSafeArea(.all) // 让图片填充整个屏幕，忽略安全区域
            
            VStack{
                Text("您本周挤奶\(records.count)次")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundStyle(.red)
                    .shadow(color: .gray, radius: 5)
                    .font(.system(size: 18))
                Text("获得称号：")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundStyle(.red)
                    .shadow(color: .gray, radius: 5)
                    .padding(.bottom)
                
                Button(action: {navigateToNextView = false}){
                    Text(title)
                        .font(.custom("zixiaohunnaitangti_T", size:25))
                        .foregroundStyle(.red)
                        .padding(.bottom, 20)
                }
                .buttonStyle(TransparentButtonStyle())
            }
        }
        .onAppear{
            prepareSound()
            playSound()
            
            if records.count == 0{
                title = "挤奶菜鸟"
            }
            else if records.count >= 1 && records.count <= 3 {
                title = "挤奶新手"
            }
            else if records.count > 3 && records.count <= 7 {
                title = "挤奶大师"
            }
            else if records.count > 7{
                title = "精尽人亡"
            }
        }
    }
    
    private func prepareSound() {
        // 准备音频文件
        if let soundURL = Bundle.main.url(forResource: "bgm_ya", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay() // 提前加载音频，防止播放延迟
            } catch {
                print("无法加载音频文件: \(error.localizedDescription)")
            }
        }
    }
    
    private func playSound() {
        audioPlayer?.play()
    }
}

/*
 #Preview {
 GoodNewsView()
 }
 */
