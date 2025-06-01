//
//  WorkoutService.swift
//  PlayNewNew Watch App
//
//  Created by Chengzhi 张 on 2024/9/7.
//

import Foundation
import HealthKit

class WorkoutManager: NSObject, ObservableObject {
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?

    func startWorkout() {
        // 定义运动配置
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .indoor

        do {
            // 创建运动会话
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()

            // 设置运动会话的委托和实时数据委托
            session?.delegate = self
            builder?.delegate = self

            // 开始会话和数据收集
            session?.startActivity(with: Date())
            builder?.beginCollection(withStart: Date(), completion: { (success, error) in
                if let error = error {
                    print("Error starting workout: \(error.localizedDescription)")
                }
            })
        } catch {
            print("Failed to start workout: \(error.localizedDescription)")
        }
    }

    func endWorkout() {
        session?.end()
        builder?.endCollection(withEnd: Date(), completion: { (success, error) in
            if let error = error {
                print("Error ending workout: \(error.localizedDescription)")
            }
        })
    }
}

extension WorkoutManager: HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for sampleType in collectedTypes {
            print("Collected data of type: \(sampleType)")
        }
        
        // 如果需要根据不同类型进行处理，可以在这里做进一步判断
        if collectedTypes.contains(HKQuantityType.quantityType(forIdentifier: .heartRate)!) {
            print("Heart rate data collected")
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        // 处理状态变化
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        // 处理错误
        print("Workout session failed: \(error.localizedDescription)")
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // 处理实时数据
    }
}
