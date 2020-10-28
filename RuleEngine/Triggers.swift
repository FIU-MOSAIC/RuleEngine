//
//  Triggers.swift
//  RuleEngine
//
//  Created by Afzal Hossain on 10/7/20.
//  Copyright © 2020 Afzal Hossain. All rights reserved.
//

import Foundation
import CoreMotion


protocol Trigger {
    
}

class EventTrigger:Trigger{
    let source:BaseSource
    let actions:[BaseAction]
    
    init(source:BaseSource, actions:[BaseAction]) {
        self.source = source
        self.actions = actions
        
        let notificationName = "\(self.source.instanceId)-\(self.source.eventSource.name)"
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.recieveData(_:)), name: NSNotification.Name(rawValue: notificationName), object: nil)
        
        self.source.start()
        print("trigger is initialized, source will start......")
    }
    
    @objc func recieveData(_ notification:NSNotification){
        //        print("djsa ------------")
        if let data = notification.userInfo!["data"] as? EventData {
            for action in actions{
                action.startAction()
            }
        }
    }
    
    deinit {
        
    }

}

class ContextTrigger:Trigger{
    
}
