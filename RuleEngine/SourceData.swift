//
//  SourceData.swift
//  RuleEngine
//
//  Created by Afzal Hossain on 10/8/20.
//  Copyright © 2020 Afzal Hossain. All rights reserved.
//

import Foundation


//enum DataType {
//    case event, context, sequence
//}


//protocol BaseData {
//    var type:DataType{get}
//    var action:KoiosActionStruct { get }
//    func toString()
//
//}

struct EventData{
    let timestamp:Int64
//    let timezone:
    var values:[String:Any] = [:]
    init(values:[String:Any]) {
        self.timestamp = Utils.currentUnixTime()
        self.values = values
    }
    
    init(timestamp:Int64, values:[String:Any]) {
        self.timestamp = timestamp
        self.values = values
    }
}

//class ContextData{
//    
//}
//
//struct SequenceData{
//        let timestamp:Int64
//    //    let timezone:
//        let values:[String:Any] = [:]
//        init() {
//            timestamp = Utils.currentUnixTime()
//        }
//}
