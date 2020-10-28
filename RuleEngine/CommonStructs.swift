//
//  CommonStructs.swift
//  RuleEngine
//
//  Created by Afzal Hossain on 10/8/20.
//  Copyright © 2020 Afzal Hossain. All rights reserved.
//

import Foundation



enum DataType {
    case string, categorical, integer, double
}

//enum EventDataType {
//    case accelerometer,
//}

struct ParameterStruct{
    let name:String
    let parent:String
    let dataType:DataType
//    let possibleValues:String?
//    let required:Bool?
//    let description:String?
    let value:String?
}

struct EventAttributeStruct{
    let name:String
    let source:String
    let dataType:DataType
//    let possibleValues:String?
    let value:String?
}

struct EventSourceStruct {
    let name:String
//    let alias:String?
//    let description:String?
//    let isActive:Int?
    let dataType:DataType?
//    let possibleValues:String?
//    let hasAttribute:Int
//    let hasParameter:Int
//    let contextSensors:String?
    let attributes:[EventAttributeStruct]?
    let params:[ParameterStruct]?
}

struct KoiosActionStruct{
    let name:String
//    let alias:String?
    let isSustained:Int
//    let isManipulative:Int?
//    let activationSensors:String?
//    let deactivationSensors:String?
//    let isActive:Int?
//    let description:String?
    let params:[ParameterStruct]?
}



class DummyData{
    
    
    
    static func getAEventSourceStruct()->EventSourceStruct{
        let connectivity = EventAttributeStruct(name: "connectivity", source: "network", dataType: .categorical, value: "")
        let ssid = EventAttributeStruct(name: "ssid", source: "network", dataType: .string, value: "")
        let bssid = EventAttributeStruct(name: "bssid", source: "network", dataType: .string, value: "")
        
        return EventSourceStruct(name: "network", dataType: nil, attributes: [connectivity, ssid, bssid], params: nil)
    }
    
    static func getAnActionStruct()->KoiosActionStruct{
        let param1 = ParameterStruct(name: "title", parent: "send_notification", dataType: .string, value: "Koios App")
        let param2 = ParameterStruct(name: "message", parent: "send_notification", dataType: .string, value: "This is a test message")
        return KoiosActionStruct(name: "send_notification", isSustained: 0, params: [param1, param2])

    }
}
