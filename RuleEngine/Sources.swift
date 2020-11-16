//
//  Sources.swift
//  RuleEngine
//
//  Created by Afzal Hossain on 10/8/20.
//  Copyright © 2020 Afzal Hossain. All rights reserved.
//

import Foundation
import CoreMotion
import UIKit


protocol BaseSource {
    var instanceId:String{get}
    var eventSource:EventSourceStruct{get}
    func start()
    func stop()
    //    func post(data:EventData)
}

extension BaseSource{
    func post(data:EventData){
        var postData = Dictionary<String, EventData>()
        //        postData["instance"] = self.instanceId
        //        postData["source"] = self.eventSource.name
        postData["data"] = data
        
        let notificationName = "\(self.instanceId)-\(self.eventSource.name)"
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationName), object: nil, userInfo: postData)
        
    }
}

class TimerSource: BaseSource {
    var instanceId: String
    
    var eventSource: EventSourceStruct
    
    init(instanceId:String, eventSource:EventSourceStruct) {
        self.instanceId = instanceId
        self.eventSource = eventSource
    }
    
    func start() {
        var timer = Timer.scheduledTimer(withTimeInterval: 1 * 60, repeats: true) { _ in
            print("in the tick function - \(Date())")
            
        }
        timer.fireDate = getNextMinute(Date())
    }
    
    func stop() {
        
    }
    
    func getNextMinute(_ toProcessDate:Date)->Date{
        let calendar:Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var componentsForProcessDate:DateComponents? = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute, .second] , from: toProcessDate)
        componentsForProcessDate!.minute = componentsForProcessDate!.minute! + 1
        componentsForProcessDate!.second = 0
        componentsForProcessDate!.timeZone = .current
        return calendar.date(from: componentsForProcessDate!)!
        
    }
}


class ActivityRecognitionSource: BaseSource {
    
    var instanceId: String
    var eventSource: EventSourceStruct
    let activityManager:CMMotionActivityManager
    
    
    init(instanceId:String, eventSource:EventSourceStruct) {
        self.instanceId = instanceId
        self.eventSource = eventSource
        activityManager = CMMotionActivityManager()
    }
    
    func start() {
        activityManager.startActivityUpdates(to:OperationQueue(), withHandler: { activity in
            
            guard let activity = activity else {
                return
            }
            var currentActivity:String = ""
            if activity.automotive{
                currentActivity = "auto"
            }else if activity.cycling{
                currentActivity = "cycling"
            }else if activity.running{
                currentActivity = "running"
            }else if activity.walking{
                currentActivity = "walking"
            }else if activity.stationary{
                currentActivity = "stationary"
            }else{
                currentActivity = "unknown"
            }
            
            var values = [String:Any]()
            values["activity"] = currentActivity
            self.post(data: EventData(values: values))
        })
    }
    
    func stop() {
        
    }
    
}

class BatteryLevelSource:BaseSource{
    var instanceId: String
    var eventSource: EventSourceStruct
    
    init(instanceId:String, eventSource:EventSourceStruct) {
        self.instanceId = instanceId
        self.eventSource = eventSource
    }
    
    func start() {
        NotificationCenter.default.addObserver(self, selector: #selector(monitorBatteryLevel(notification:))
            , name:UIDevice.batteryLevelDidChangeNotification, object: nil)
        
    }
    
    func stop() {
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        
    }
    @objc private func monitorBatteryLevel(notification:NSNotification?){
        let level = UIDevice.current.batteryLevel
        var values = [String:Any]()
        values["battery_level"] = Int(level * 100)
        self.post(data: EventData(values: values))
    }
}

class BatteryStateSource:BaseSource{
    var instanceId: String
    
    var eventSource: EventSourceStruct
    
    init(instanceId:String, eventSource:EventSourceStruct) {
        self.instanceId = instanceId
        self.eventSource = eventSource
    }
    
    func start() {
        NotificationCenter.default.addObserver(self, selector: #selector(monitorBatteryState(notification:)), name:UIDevice.batteryStateDidChangeNotification, object: nil)
        
    }
    
    func stop() {
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryStateDidChangeNotification, object: nil)
    }
    @objc private func monitorBatteryState(notification:NSNotification?){
        let state:Int = UIDevice.current.batteryState.rawValue
        var status:String = ""
        if(state == 1){
            status = "unplugged"
        } else if (state == 2){
            status = "charging"
        } else if(state == 3){
            status = "full"
        } else {
            status = "unknown"
        }
        
        var values = [String:Any]()
        values["battery_state"] = status
        self.post(data: EventData(values: values))        
    }
    
}

class NetworkSource:BaseSource{
    let reachability: Reachability?
    var instanceId: String
    
    var eventSource: EventSourceStruct
    
    init(instanceId:String, eventSource:EventSourceStruct) {
        self.instanceId = instanceId
        self.eventSource = eventSource
        reachability = try? Reachability()
    }
    
    func start() {
        print("going to register for reachability event....")
        if reachability != nil{
            NotificationCenter.default.addObserver(self, selector:#selector(self.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
            
            do {
                try self.reachability!.startNotifier()
                
            }
            catch(let error) {
                print("Error occured while starting reachability notifications : \(error.localizedDescription)")
            }
            
        }
    }
    
    func stop() {
        if reachability != nil{
            self.reachability!.stopNotifier()
            NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        var values = [String:Any]()
        switch reachability.connection {
        case .cellular:
            print("Network available via Cellular Data.")
            values["connectivity"] = "cellular"
            self.post(data: EventData(values: values))
            break
        case .wifi:
            print("Network available via WiFi.")
            let wifiInfo:[String] = Utils.getInterfaces()
            var bssid:String = ""
            var ssid:String = ""
            if(wifiInfo.count == 2){
                ssid = wifiInfo[0]
                bssid = wifiInfo[1]
                if bssid.starts(with: "00:00"){
                    bssid = ""
                }
            }
            values["\(eventSource.name).connectivity"] = "wifi"
            values["\(eventSource.name).ssid"] = ssid
            values["\(eventSource.name).bssid"] = bssid
            self.post(data: EventData(values: values))
            break
        case .none, .unavailable:
            values["connectivity"] = "none"
            self.post(data: EventData(values: values))
            break
        }
    }
}


class AccelerometerSource:BaseSource{
    let motionManager = CMMotionManager()
    let frequencyParamName = "frequency"
    
    var instanceId: String
    var eventSource: EventSourceStruct
    
    var frequency:Double = 0
    
    init(instanceId:String, eventSource:EventSourceStruct) {
        self.instanceId = instanceId
        self.eventSource = eventSource
        for param in eventSource.params{
            if param.name == frequencyParamName{
                frequency = Double(param.value) ?? 0
            }
        }
    }
    
    func start() {
        if self.frequency <= 0{
            return
        }
        
        if(motionManager.isAccelerometerAvailable){
            motionManager.accelerometerUpdateInterval = (1.0/self.frequency)
            motionManager.startAccelerometerUpdates(to: OperationQueue(), withHandler:
                {data,error in
                    
                    guard let data = data else{
                        return
                    }
                    var values = [String:Any]()
                    values["x"] = data.acceleration.x
                    values["y"] = data.acceleration.y
                    values["z"] = data.acceleration.z
                    self.post(data: EventData(timestamp: Int64(data.timestamp), values: values))
            }
            )
            
        }
    }
    
    func stop() {
        motionManager.stopAccelerometerUpdates()
    }
    
    
}


