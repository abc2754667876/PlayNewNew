//
//  ConnectivityManager.swift
//  PlayNewNewOnIOS
//
//  Created by Chengzhi 张 on 2024/9/14.
//

import Foundation
import WatchConnectivity

class ConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    
    // 创建单例实例
    static let shared = ConnectivityManager()
    
    override private init() {
        super.init()
        setupSession()
    }
    
    func setupSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // 处理从 watchOS 接收到的消息
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let receivedData = message["dataKey"] as? String {
                print("Received data from watchOS: \(receivedData)")
                // 在这里处理收到的数据
            }
        }
    }
    
    // 必须实现的 WCSessionDelegate 方法之一
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // 处理激活状态变化
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }
    
    // 必须实现的 WCSessionDelegate 方法
    func sessionDidBecomeInactive(_ session: WCSession) {
        // 当 session 变为非活动状态时
        print("WCSession became inactive")
    }
    
    // 必须实现的 WCSessionDelegate 方法
    func sessionDidDeactivate(_ session: WCSession) {
        // 当 session 被关闭时
        print("WCSession deactivated")
        
        // 在此调用 activate() 来重新激活 session（如果需要）
        session.activate()
    }
}
