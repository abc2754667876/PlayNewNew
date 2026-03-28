//
//  GoodNewsView.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/9/18.
//

import SwiftUI

struct GoodNewsView: View {
    @ObservedObject var viewModel: GoodNewsViewModel
    @Binding var navigateToNextView: Bool

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Image("background")
                    .resizable()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .edgesIgnoringSafeArea(.all)

            VStack {
                Text(viewModel.weekCountText)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                    .shadow(color: .gray, radius: 5)
                    .font(.system(size: 18))
                Text("获得称号：")
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                    .shadow(color: .gray, radius: 5)
                    .padding(.bottom)

                Button(action: { navigateToNextView = false }) {
                    Text(viewModel.title)
                        .font(.custom("zixiaohunnaitangti_T", size: 25))
                        .foregroundStyle(.red)
                        .padding(.bottom, 20)
                }
                .buttonStyle(TransparentButtonStyle())
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}
