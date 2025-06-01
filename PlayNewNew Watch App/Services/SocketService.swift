//
//  SocketService.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/8/26.
//

import Foundation
import Network
import Combine

class SocketClient: ObservableObject {
    private var connection: NWConnection?
    @Published var receivedText: String = "" // 用于存储接收到的消息
    var messageReceived = PassthroughSubject<String, Never>() // 用于发布接收到的消息
    
    init() {
        if GlobalData.shared.accessRank{
            connectToServer()
        }
    }
    
    func connectToServer(){
        let host = NWEndpoint.Host("121.36.58.172") // 服务端的IP地址
        let port = NWEndpoint.Port(integerLiteral: 21) // 服务端监听的端口号
        
        connection = NWConnection(host: host, port: port, using: .tcp)
        connection?.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("Connected to server")
                self.receiveMessage() // 连接成功后开始接收消息
            case .failed(let error):
                print("Connection failed with error: \(error)")
            case .waiting(let error):
                print("Connection is waiting with error: \(error)")
                // Retry or handle waiting state
            case .preparing:
                print("Connection is preparing")
            default:
                break
            }
        }
        connection?.start(queue: .global())
    }
    
    func sendMessage(_ message: String) {
        guard let connection = connection else { return }
        let data = message.data(using: .utf8)!
        connection.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                print("Failed to send message with error: \(error)")
            } else {
                print("Message sent: \(message)")
            }
        }))
    }
    
    private func receiveMessage() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 1024, completion: { data, _, _, error in
            if let data = data, !data.isEmpty {
                if let receivedMessage = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.receivedText = receivedMessage
                        self.messageReceived.send(receivedMessage) // 发送接收到的消息
                        //print("Message received: \(receivedMessage)")
                    }
                }
                self.receiveMessage() // 递归调用，继续接收后续消息
            } else if let error = error {
                print("Failed to receive message with error: \(error)")
            }
        })
    }
    
    func stopConnection() {
        connection?.cancel()
        print("Connection stopped")
    }
}
