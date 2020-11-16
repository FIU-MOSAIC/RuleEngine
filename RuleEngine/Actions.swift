//
//  Actions.swift
//  RuleEngine
//
//  Created by Afzal Hossain on 10/8/20.
//  Copyright © 2020 Afzal Hossain. All rights reserved.
//

import Foundation
import CoreMotion
import UIKit

enum ActionType {
    case instantaneous, sustained
}

protocol BaseAction {
    var type:ActionType{get}
    var action:KoiosActionStruct { get }
    func startAction()
}

protocol InstantaneousAction: BaseAction {
    
}

extension InstantaneousAction{
    var type: ActionType{
        get{
            return ActionType.instantaneous
        }
    }
}
protocol SustainedAction:BaseAction{
    func stopAction()
}

extension SustainedAction{
    var type: ActionType{
        get{
            return ActionType.sustained
        }
    }
}

struct test:InstantaneousAction {
    var action: KoiosActionStruct
    
    func startAction() {
        print("this is a test")
    }
    
    
}

class LogData:InstantaneousAction{
    var action: KoiosActionStruct
    
    init(action:KoiosActionStruct) {
        self.action = action
    }
    
    func startAction() {
        
    }
    
}

class PeriodicAccelerometerData:SustainedAction{
    var action: KoiosActionStruct
    
    let motionManager:CMMotionManager
    let frequencyParamName = "frequency"
    var frequency:Double = 0
    
    init(instanceId:String, action:KoiosActionStruct) {
        self.action = action
        motionManager = CMMotionManager()
        for param in action.params{
            if param.name == frequencyParamName{
                frequency = Double(param.value) ?? 0
            }
        }
    }
    func startAction() {
        if self.frequency <= 0{
            return
        }
        
        if(motionManager.isAccelerometerAvailable){
            motionManager.accelerometerUpdateInterval = (1.0/self.frequency)
            motionManager.startAccelerometerUpdates(to: OperationQueue(), withHandler:
                {data,error in
                    //if let isError = error{
                    //println("error reading accel data :\(isError)")
                    //}
                    guard let data = data else{
                        return
                    }
                    
                    print("action data of accel -, timestamp:\(Utils.currentLocalTimeWithMillisAndZoneInfo()) x:\(data.acceleration.x), y:\(data.acceleration.y), z:\(data.acceleration.z)")
                }
            )
        }
    }
    
    func stopAction() {
        motionManager.stopAccelerometerUpdates()
    }
}

class PeriodicGyroscopeData:SustainedAction{
    var action: KoiosActionStruct
    
    let motionManager:CMMotionManager
    let frequencyParamName = "frequency"
    var frequency:Double = 0
    
    init(instanceId:String, action:KoiosActionStruct) {
        self.action = action
        motionManager = CMMotionManager()
        for param in action.params{
            if param.name == frequencyParamName{
                frequency = Double(param.value) ?? 0
            }
        }
    }
    func startAction() {
        if self.frequency <= 0{
            return
        }
        
        if(motionManager.isGyroAvailable){
            motionManager.gyroUpdateInterval = (1.0/self.frequency)
            motionManager.startGyroUpdates(to: OperationQueue(), withHandler:
                {data,error in
                    //if let isError = error{
                    //println("error reading accel data :\(isError)")
                    //}
                    guard let data = data else{
                        return
                    }
                    
                    print("action data of accel -, timestamp:\(Utils.currentLocalTimeWithMillisAndZoneInfo()) x:\(data.rotationRate.x), y:\(data.rotationRate.y), z:\(data.rotationRate.z)")
                }
            )
        }
    }
    
    func stopAction() {
        motionManager.stopGyroUpdates()
    }
}

class PeriodicMagnetometerData:SustainedAction{
    var action: KoiosActionStruct
    
    let motionManager:CMMotionManager
    let frequencyParamName = "frequency"
    var frequency:Double = 0
    
    init(instanceId:String, action:KoiosActionStruct) {
        self.action = action
        motionManager = CMMotionManager()
        for param in action.params{
            if param.name == frequencyParamName{
                frequency = Double(param.value) ?? 0
            }
        }
    }
    func startAction() {
        if self.frequency <= 0{
            return
        }
        
        if(motionManager.isMagnetometerAvailable){
            motionManager.magnetometerUpdateInterval = (1.0/self.frequency)
            motionManager.startMagnetometerUpdates(to: OperationQueue(), withHandler:
                {data,error in
                    //if let isError = error{
                    //println("error reading accel data :\(isError)")
                    //}
                    guard let data = data else{
                        return
                    }
                    
                    print("action data of accel -, timestamp:\(Utils.currentLocalTimeWithMillisAndZoneInfo()) x:\(data.magneticField.x), y:\(data.magneticField.y), z:\(data.magneticField.z)")
                }
            )
        }
    }
    
    func stopAction() {
        motionManager.startMagnetometerUpdates()
    }
}

class SendNotificationAction:InstantaneousAction{
    var action: KoiosActionStruct
    
    let titleParamName = "title"
    let messageParamName = "message"
    
    var title:String = ""
    var message:String = ""
    
    init(instanceId:String, action:KoiosActionStruct) {
        self.action = action
        for param in action.params{
            if param.name == titleParamName{
                title = param.value
            }else if param.name == messageParamName{
                message = param.value
            }
        }
    }
    
    func startAction() {
        if title.isEmpty && message.isEmpty{
            return
        }
        print("time:\(Utils.currentLocalTimeWithMillisAndZoneInfo()), send notification \(title), \(message)")
    }
}


class BatteryStateAction:InstantaneousAction{
    var action: KoiosActionStruct
        
    init(instanceId:String, action:KoiosActionStruct) {
        self.action = action
    }
    
    func startAction() {
        //print("current battery state:\(UIDevice.BatteryState.)")
        
    }
}

class BatteryLevelAction:InstantaneousAction{
    var action: KoiosActionStruct
        
    init(instanceId:String, action:KoiosActionStruct) {
        self.action = action
    }
    
    func startAction() {
        //print("current battery state:\(UIDevice.BatteryState.)")
        
    }
}

