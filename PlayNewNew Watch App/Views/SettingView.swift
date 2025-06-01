//
//  SettingView.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/8/20.
//

import SwiftUI
import Combine

struct SettingView: View {
    @State private var clear_ShowAlert = false
    @State private var clear_IsConfirmed = false
    
    @AppStorage("isOpen") private var isOpen: Bool = false
    @AppStorage("userName") private var userName: String = "-"
    @AppStorage("isSoundOpen") private var isSoundOpen = true
    @State private var showInputView: Bool = false
    @State private var inputName: String = ""
    @State private var showAlert: Bool = false
    @State private var alertInfo: String = ""
    
    @State private var debugMode = false
    
    @StateObject private var socketClient = SocketClient()
    @State private var cancellable: AnyCancellable?
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack{
                    HStack{
                        Text("⚙ 通用设置")
                            .font(.custom("zixiaohunnaitangti_T", size:15))
                        Spacer()
                    }
                    .padding(.top, 25)
                    
                    if GlobalData.shared.accessRank{
                        HStack{
                            Text("参与排行榜")
                                .font(.custom("zixiaohunnaitangti_T", size:14))
                            
                            Spacer()
                            
                            Toggle("", isOn: $isOpen)
                                .onReceive(Just(isOpen)) { newValue in
                                    handleToggleChange_Rank()
                                }
                                .padding()
                        }
                        .padding(.bottom, 1)
                        
                        HStack{
                            Text("当前用户名：\(userName)")
                                .font(.custom("zixiaohunnaitangti_T", size:12))
                                .opacity(0.5)
                            
                            Spacer()
                        }
                        .padding(.bottom)

                        Divider()
                            .padding(.bottom)
                    }
                    
                    HStack{
                        Text("播放音效")
                            .font(.custom("zixiaohunnaitangti_T", size:14))
                        
                        Spacer()
                        
                        Toggle("", isOn: $isSoundOpen)
                            .onReceive(Just(isSoundOpen)) { newValue in
                                handleToggleChange_Sound()
                            }
                            .padding()
                    }
                    
                    Divider()
                        .padding(.bottom)
                    
                    HStack{
                        Text("⚙ 挤奶灵敏度设置")
                            .font(.custom("zixiaohunnaitangti_T", size:15))
                        Spacer()
                    }
                    
                    NavigationLink(destination: SettingView_AccelerationThresholdSetting()){
                        Text("挤奶灵敏度设置")
                            .font(.custom("zixiaohunnaitangti_T", size:14))
                    }
                    .padding(.bottom)
                    .padding(.top)
                    
                    Divider()
                        .padding(.bottom)
                    
                    Button(action:{
                        clearDataRecords()
                    }){
                        Text("清除挤奶数据")
                            .font(.custom("zixiaohunnaitangti_T", size:14))
                            .foregroundStyle(.red)
                    }
                    
                    Text("当前版本：\(appVersion)")
                        .padding(.top, 5)
                        .font(.custom("zixiaohunnaitangti_T", size:12))
                        .opacity(0.7)
                    
                    if debugMode{
                        Divider()
                            .padding(.bottom)
                            .padding(.top)
                        Button(action: {
                            deleteUsername()
                        }){
                            Text("删除用户名")
                                .font(.custom("zixiaohunnaitangti_T", size:14))
                        }
                    }
                    
                    Spacer()
                }
                .sheet(isPresented: $showInputView) {
                    UsernameInputView(username: $inputName, onSave: handleSave)
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("提示"),
                        message: Text(alertInfo),
                        dismissButton: .default(Text("确定"))
                    )
                }
                .onDisappear{
                    cancellable?.cancel()
                    socketClient.stopConnection()
                }
            }
        }
    }
    
    var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "未知"
    }
    
    private func handleToggleChange_Rank() {
        // 当 Toggle 状态改变时，isOpen 的值会自动保存到 UserDefaults 中
        if isOpen && userName == "-" {
            // 如果用户名为空并且开启了 Toggle，显示输入视图
            showInputView = true
        }
    }
    
    private func handleToggleChange_Sound(){
        
    }
    
    private func handleSave() {
        if inputName.count < 2 || inputName.contains("|") || inputName.contains("*") {
            isOpen = false
            showInputView = false // 先关闭 Sheet
            alertInfo = "用户名必须大于1个字符，或含有非法字符"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showAlert = true // 延迟后再显示 Alert
            }
        } else {
            checkUserName(userName: inputName)
        }
    }
    
    private func deleteUsername() {
        isOpen = false
        userName = "-" // 清空保存的用户名
    }
    
    private func checkUserName(userName: String) {
        let json_CheckUserName = JSON_CheckUserName(command: "CheckUserName", userName: userName)
        let sendString = encodeToJSON(object: json_CheckUserName)
        socketClient.sendMessage(sendString ?? "nil")
        
        cancellable = socketClient.messageReceived
            .sink { receivedMessage in
                if let parsedData = parseJSON(jsonString: receivedMessage){
                    let jsonDict = parsedData as? [String: Any]
                    let command = jsonDict?["command"] as? String
                    let result1 = jsonDict?["result"] as? String
                    if command == "CheckUserName"{
                        print("result:" + result1!)
                        if result1 == "exit" {
                            isOpen = false
                            showInputView = false // 先关闭 Sheet
                            alertInfo = "保存用户名失败，该用户名已存在"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showAlert = true // 延迟后再显示 Alert
                            }
                        } else if result1 == "true" {
                            self.userName = inputName.trimmingCharacters(in: .whitespaces)
                            showInputView = false
                            alertInfo = "保存用户名成功"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showAlert = true // 延迟后再显示 Alert
                            }
                        }
                    }
                }
            }
    }
}

struct UsernameInputView: View {
    @Binding var username: String
    var onSave: () -> Void

    var body: some View {
        VStack {
            Text("创建一个用户名：")
            TextField("请输入用户名", text: $username)
                .padding()

            Button("确定") {
                onSave()
            }
            .padding()
        }
    }
}

#Preview {
    SettingView()
}
