//
//  SourceFactory.swift
//  RuleEngine
//
//  Created by Afzal Hossain on 11/5/20.
//  Copyright © 2020 Afzal Hossain. All rights reserved.
//

import Foundation


class ClassFactory{
    
    static func getSourceClass(instanceId:String, sourceStruct:EventSourceStruct)->BaseSource?{
        if sourceStruct.name == "accelerometer"{
            print("I am here to get the accelerometer....")
            return AccelerometerSource(instanceId: instanceId, eventSource: sourceStruct)
        }
        else if sourceStruct.name == "activity" {
            //Bundle.main.classNamed(ActivityRecognitionSource.)
            return ActivityRecognitionSource(instanceId: instanceId, eventSource: sourceStruct)
        }else if sourceStruct.name == "battery_level"{
            return BatteryLevelSource(instanceId: instanceId, eventSource: sourceStruct)
        }else if sourceStruct.name == "battery_state"{
            return BatteryStateSource(instanceId: instanceId, eventSource: sourceStruct)
        }else if sourceStruct.name == "gyroscope"{
            
        }else if sourceStruct.name == "magnetometer"{
            
        }else if sourceStruct.name == "minute_timer"{
            return TimerSource(instanceId: instanceId, eventSource: sourceStruct)
        }else if sourceStruct.name == "network"{
            return NetworkSource(instanceId: instanceId, eventSource: sourceStruct)
        }else if sourceStruct.name == "screen_display"{
            //
        }else if sourceStruct.name == "screen_state"{
            //
        }
        
        return nil
    }
    
    
    static func getActionClass(instanceId:String, actionStruct:KoiosActionStruct)->BaseAction?{
        if actionStruct.name == "accel_update_periodic"{
            return PeriodicAccelerometerData(instanceId: instanceId, action: actionStruct)
        }else if actionStruct.name == "gps_update_periodic" {
            //TODO:
        }else if actionStruct.name == "gyro_update_periodic"{
            return PeriodicGyroscopeData(instanceId: instanceId, action: actionStruct)
        }else if actionStruct.name == "magnet_update_periodic"{
            return PeriodicMagnetometerData(instanceId: instanceId, action: actionStruct)
        }else if actionStruct.name == "battery_level"{
            
        }else if actionStruct.name == "battery_state"{
            
        }else if actionStruct.name == "current_gps"{
            
        }else if actionStruct.name == "send_notification"{

        }else if actionStruct.name == "wifi_state"{
            
        }
        
        return nil
    }
}
