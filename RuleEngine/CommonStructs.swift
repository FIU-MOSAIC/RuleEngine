//
//  CommonStructs.swift
//  RuleEngine
//
//  Created by Afzal Hossain on 10/8/20.
//  Copyright © 2020 Afzal Hossain. All rights reserved.
//

import Foundation
import SwiftyJSON


enum DataType:String {
    case string, categorical, integer, double, none
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
    var value:String
    
    func toString()->String{
        return "param name:\(name), parent:\(parent), dataType:\(dataType.rawValue), value:\(value)"
    }
}

struct EventAttributeStruct{
    let name:String
    let source:String
    let dataType:DataType
//    let possibleValues:String?
    var value:String
    
    func toString()->String{
        return "attribute name:\(name), source:\(source), dataType:\(dataType.rawValue), value:\(value)"
    }
}

struct EventSourceStruct {
    let name:String
//    let alias:String?
//    let description:String?
//    let isActive:Int?
    let dataType:DataType
//    let possibleValues:String?
//    let hasAttribute:Int
//    let hasParameter:Int
//    let contextSensors:String?
    var attributes:[EventAttributeStruct]
    var params:[ParameterStruct]
    
    func toString()->String{
        if params.count>0 {
            print("param from to string: \(params[0].toString())")
        }
        return "name:\(name), dataType:\(dataType.rawValue), param:\(params.forEach{$0.toString()}), attributes:\(attributes.forEach({$0.toString()})))"
    }

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
    var params:[ParameterStruct]
}

struct TriggerStruct{
//    var instanceId:String
//    var type:String
    var expression:String
    var conditionType:String
    var persistanceDuration:Int
    var windowType:String
    var windowValue:Int
    var contextFunction:String
    var functionOperator:String
    var functionValue:String
    
    static func responseFromJSONData(jsonData:JSON)->TriggerStruct{
        let expression = jsonData["contextExpression"].stringValue
        let conditionType = jsonData["conditionType"].stringValue
        let persistanceDuration = jsonData["persistanceDuration"].intValue
        let windowType = jsonData["windowType"].stringValue
        let windowValue = jsonData["windowValue"].intValue
        let contextFunction = jsonData["contextFunction"].stringValue
        let functionOperator = jsonData["functionOperator"].stringValue
        let functionValue = jsonData["functionValue"].stringValue
        
        return TriggerStruct(expression: expression, conditionType: conditionType, persistanceDuration: persistanceDuration, windowType: windowType, windowValue: windowValue, contextFunction: contextFunction, functionOperator: functionOperator, functionValue: functionValue)
    }
    
    func toString()->String{
        return "expression:\(expression), conditionType:\(conditionType), persistanceDuration:\(persistanceDuration), windowType:\(windowType), windowValue:\(windowValue), contextFunction\(contextFunction), functionOperator:\(functionOperator), functionValue:\(functionValue)"
    }
}

struct TriggerActionMappingStruct{
    var studyId:Int16
    var sensorConfigId:Int16
//    var version:Int16
    var mappingId:Int16
    var sources:String
    var triggerType:String
    var triggerJson:String
    var actions:String
    
    static func responseFromJSONData(jsonData:JSON)->TriggerActionMappingStruct{
        let studyId = Int16(jsonData["studyId"].intValue)
        let sensorConfigId = Int16(jsonData["sensorConfigId"].intValue)
        let mappingId = Int16(jsonData["mappingId"].intValue)
        let sources = jsonData["sources"].stringValue
        let triggerType = jsonData["type"].stringValue
        let triggerJson = jsonData["triggerString"].stringValue
        let actions = jsonData["actions"].stringValue
        
        return TriggerActionMappingStruct(studyId: studyId, sensorConfigId: sensorConfigId, mappingId: mappingId, sources: sources, triggerType: triggerType, triggerJson: triggerJson, actions: actions)
    }
}

struct SensorConfigStruct{
    var id:Int16
    var studyId:Int16
    var version:Int16
    var state:Int16
    var lifecycle:Int16
    static func responseFromJSONData(jsonData:JSON)->SensorConfigStruct{
        let id = Int16(jsonData["id"].intValue)
        let studyId = Int16(jsonData["studyId"].intValue)
        let version = Int16(jsonData["publishedVersion"].intValue)
        let state = Int16(jsonData["state"].intValue)
        let lifecycle = Int16(jsonData["lifecycle"].intValue)
        return SensorConfigStruct(id: id, studyId: studyId, version: version, state: state, lifecycle: lifecycle)
    }
}

struct StudyStruct{
    var studyId:Int16
    var name:String
    var studyDescription:String?
    var instruction:String?
    var modificationTime:String?
    var state:Int16
    var iconUrl:String?
    
    static func responseFromJSONData(jsonData:JSON)->StudyStruct{
        let studyId = Int16(jsonData["id"].intValue)
        let name = jsonData["name"].stringValue
        let studyDescription = jsonData["description"].stringValue
        let instruction = jsonData["instruction"].stringValue
        let modificationTime = jsonData["modificationTime"].stringValue
        let state = Int16(jsonData["state"].intValue)
        let iconUrl = jsonData["iconUrl"].stringValue

        return StudyStruct(studyId: studyId, name: name, studyDescription: studyDescription, instruction: instruction, modificationTime: modificationTime, state: state, iconUrl: iconUrl)
    }

}



class DummyData{
    
    
    
//    static func getAEventSourceStruct()->EventSourceStruct{
//        let connectivity = EventAttributeStruct(name: "connectivity", source: "network", dataType: .categorical, value: "")
//        let ssid = EventAttributeStruct(name: "ssid", source: "network", dataType: .string, value: "")
//        let bssid = EventAttributeStruct(name: "bssid", source: "network", dataType: .string, value: "")
//
//        return EventSourceStruct(name: "network", dataType: nil, attributes: [connectivity, ssid, bssid], params: nil)
//    }
//
//    static func getAnActionStruct()->KoiosActionStruct{
//        let param1 = ParameterStruct(name: "title", parent: "send_notification", dataType: .string, value: "Koios App")
//        let param2 = ParameterStruct(name: "message", parent: "send_notification", dataType: .string, value: "This is a test message")
//        return KoiosActionStruct(name: "send_notification", isSustained: 0, params: [param1, param2])
//
//    }
}
