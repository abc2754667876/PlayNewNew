//
//  JSONService.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/8/26.
//

import Foundation

func encodeToJSON<T: Codable>(object: T) -> String? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted // 可选，设置为 .prettyPrinted 可以获得更易读的 JSON 字符串
    do {
        let jsonData = try encoder.encode(object)
        return String(data: jsonData, encoding: .utf8)
    } catch {
        print("Failed to encode object to JSON: \(error)")
        return nil
    }
}

func parseJSON(jsonString: String) -> Any? {
    // 将 JSON 字符串转换为 Data
    guard let jsonData = jsonString.data(using: .utf8) else {
        print("Invalid JSON string")
        return nil
    }
    
    do {
        // 使用 JSONSerialization 解析 JSON 数据
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
        return jsonObject
    } catch {
        print("Failed to parse JSON: \(error)")
        return nil
    }
}

struct JSON_CheckUserName: Codable {
    let command: String
    let userName: String
}

struct JSON_PlayLog: Codable{
    let userName: String
    let time: String
    let spend: Int
    let count: Int
    let frequency: Double
    let heartRate: Double
    let command: String
}

struct JSON_RequestRank: Codable{
    let command: String
    let type: String
}
