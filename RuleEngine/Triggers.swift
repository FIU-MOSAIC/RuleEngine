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
    func start()
    
    func stop()
}

class EventTrigger:Trigger{
    let source:BaseSource
    let actions:[BaseAction]
    
    init(source:BaseSource, actions:[BaseAction]) {
        self.source = source
        self.actions = actions
        
    }
    
    func start(){
        let notificationName = "\(self.source.instanceId)-\(self.source.eventSource.name)"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.recieveData(_:)), name: NSNotification.Name(rawValue: notificationName), object: nil)
        
        self.source.start()
        print("trigger is initialized, source will start......")
    }
    
    func stop(){
        let notificationName = "\(self.source.instanceId)-\(self.source.eventSource.name)"
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: notificationName), object: nil)
    }
    
    @objc func recieveData(_ notification:NSNotification){
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
    let sources:[BaseSource]
    let contextTree:ContextTree
    let actions:[BaseAction]
    
    init(sources:[BaseSource], contextTree:ContextTree, actions:[BaseAction]) {
        self.sources = sources
        self.contextTree = contextTree
        self.actions = actions
    }
    
    func start(){
        for source in sources{
            let notificationName = "\(source.instanceId)-\(source.eventSource.name)"

            NotificationCenter.default.addObserver(self, selector: #selector(self.recieveData(_:)), name: NSNotification.Name(rawValue: notificationName), object: nil)
            source.start()
        }
    }
    
    func stop(){
        for source in sources{
            let notificationName = "\(source.instanceId)-\(source.eventSource.name)"
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: notificationName), object: nil)
            source.stop()
        }
    }
    
    @objc func recieveData(_ notification:NSNotification){
        if let data = notification.userInfo!["data"] as? EventData {
            let currentState = contextTree.currentState()
            contextTree.updateTreeState(data: data)
            let stateAfterEvent = contextTree.currentState()
            
            
            if !currentState && stateAfterEvent{
                //false -> true transition
                for action in actions {
                    action.startAction()
                }
            }else if currentState && !stateAfterEvent {
                //true -> false transition
                for action in actions{
                    if action is SustainedAction {
                        (action as! SustainedAction).stopAction()
                    }
                }
            }
        }

    }
}
