//
//  RuleEngine.swift
//  RuleEngine
//
//  Created by Afzal Hossain on 10/9/20.
//  Copyright © 2020 Afzal Hossain. All rights reserved.
//

import Foundation


class RuleEngine{
    
    static let sharedInstance = RuleEngine()
    
    var testTrigger:EventTrigger? = nil
    var source:NetworkSource? = nil
    var action:SendNotificationAction? = nil

//
//    init() {
//
//    }
    
    func start(){
        
        source = NetworkSource(instanceId: "1-1-1", eventSource: DummyData.getAEventSourceStruct())
        
        action = SendNotificationAction(action: DummyData.getAnActionStruct())
        
        testTrigger = EventTrigger(source: source!, actions: [action!])
    }
    
    func stop(){
        
    }
    
    func reset(){
        
    }
}
