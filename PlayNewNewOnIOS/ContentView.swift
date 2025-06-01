//
//  ContentView.swift
//  PlayNewNewOnIOS
//
//  Created by Chengzhi 张 on 2024/9/14.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .onAppear{
            ConnectivityManager.shared.setupSession()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
