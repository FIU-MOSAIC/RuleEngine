//
//  Actions.swift
//  RuleEngine
//
//  Created by Afzal Hossain on 10/8/20.
//  Copyright © 2020 Afzal Hossain. All rights reserved.
//

import Foundation
import CoreMotion

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
    
    init(action:KoiosActionStruct) {
        self.action = action
        motionManager = CMMotionManager()
        
        if let params = action.params{
            for param in params{
                if param.name == frequencyParamName{
                    if let value = param.value{
                        frequency = Double(value) ?? 0
                    }else{
                        //TODO: raise an error of wrong data type
                    }
                }
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

class SendNotificationAction:InstantaneousAction{
    var action: KoiosActionStruct
    
    let titleParamName = "title"
    let messageParamName = "message"
    
    var title:String = ""
    var message:String = ""
    
    init(action:KoiosActionStruct) {
        self.action = action
        if let params = action.params{
            for param in params{
                if param.name == titleParamName{
                    if let value = param.value{
                        title = value
                    }else{
                        //TODO: raise an error of wrong data type
                    }
                }else if param.name == messageParamName{
                    if let value = param.value{
                        message = value
                    }
                }
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

