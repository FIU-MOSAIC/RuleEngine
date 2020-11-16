//
//  Utils.swift
//  cimonv2
//
//  Created by Afzal Hossain on 2/13/18.
//  Copyright © 2018 Afzal Hossain. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import SystemConfiguration.CaptiveNetwork
//import Alamofire
//import SwiftyJSON

extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}


class Utils: NSObject {
    
    
    static var dateTimeMillisZoneFormatter:DateFormatter{
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss SSSS ZZZ"
        return dateFormatter
    }
    
    
    
    // Mark: Dictionary functions
    
    /**
     A static function to save data to user default dictionary. This dictionary should be used in limited manner. Values that are related to user.
     
     Parameters: data (any type), string key
     */
    static func saveDataToUserDefaults(data:Any, key:String){
        UserDefaults.standard.set(data, forKey: key)
    }
    
    /**
     A static method to retrieve data from user defaults dictionary. Data was saved in Any type, so it is caller's responsibility to cast properly.
     Parameters: string key
     */
    static func getDataFromUserDefaults(key:String)->Any?{
        return UserDefaults.standard.object(forKey: key)
    }
    
    /**
     */
    static func removeDataFromUserDefault(key:String){
        UserDefaults.standard.removeObject(forKey:key)
    }
    
    //Mark: Date, Time
    
    @objc static func currentUnixTime() -> Int64{
        return Int64(NSDate().timeIntervalSince1970 * 1000)
    }
    
    static func currentUnixTimeUptoSec() -> Int64{
        return Int64(NSDate().timeIntervalSince1970)
    }
    static func currentLocalTimeWithMillisAndZoneInfo()-> String{
        if let currentTime = dateTimeMillisZoneFormatter.string(from: Date()) as String?{
            return currentTime
        } else{
            return ""
        }
    }
    static func datetimefilename(date:Date!)-> String{
        if let inputDate = date{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd'_'HHmmss"
            return dateFormatter.string(from: inputDate)
        }
        return ""
    }
    
    
    static func stringFromDate(date:Date!)->String{
        if let inputDate = date{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return dateFormatter.string(from: inputDate)
        }
        return ""
    }
    
    static func dateOnlyFromToday(_ days:Int)-> String{
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentTime:String = dateFormatter.string(from: Date().addingTimeInterval( TimeInterval(days) * 24 * 3600))
        return currentTime
    }
    
    static func dateStringFromDate(_ date: Date)-> String{
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString:String = dateFormatter.string(from: date)
        return dateString
    }
    
    //MARK: default values
    static var defaultOrganization:String{
        return "University of Notre Dame"
    }
    
    // Mark: Web services
    /**
     */
    static func getBaseUrl()->String{
        //return "http://129.74.247.110/cimoninterface/"
        //return "https://koiosplatform.com/mcsweb/cimoninterface/"
        return "https://koiosplatform.com/cimoninterface/"
    }
    
    // Mark: device
    static func getDeviceIdentifier()->String{
        //return getDataFromUserDefaults(key: "anonymizer") as! String
        
        if let anonymizer = getDataFromUserDefaults(key: "anonymizer"){
            return anonymizer as! String
        }else{
            let uuid:String = (UIDevice.current.identifierForVendor?.uuidString)!
            return uuid
        }
        
    }
    
    static func getAppDisplayName()->String{
        
        if let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String{
            return displayName
        }
        return "System"
    }
    
    
    //Mark: plist file
    
    //load dictionary from plist file
    static func loadPlistData(plistFileName:String)->NSMutableDictionary {
        
        // getting path to GameData.plist
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! NSString
        let path = documentsDirectory.appendingPathComponent(plistFileName + ".plist")
        
        let fileManager = FileManager.default
        //fileManager.removeItemAtPath(path, error: nil)
        
        
        if let bundlePath = Bundle.main.path(forResource: plistFileName, ofType: "plist") {
            
            let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
            print("Bundle state.plist file is --> \(String(describing: resultDictionary?.description))")
            //check if file exists
            if(!fileManager.fileExists(atPath: path)) {
                // If it doesn't, copy it from the default file in the Bundle
                
                do{
                    try fileManager.copyItem(atPath: bundlePath, toPath: path)
                    
                } catch let error as NSError{
                    print("an error occured..\(error)")
                }
                print("copy")
                
            } else {
                print("\(String(describing: plistFileName)).plist already exits at path.")
                // use this to delete file from documents directory
                //            fileManager.removeItemAtPath(path, error: nil)
                let d1:[String:Any] = NSDictionary(contentsOfFile: path) as! [String : Any]
                let d2:[String:Any] = NSDictionary(contentsOfFile: bundlePath) as! [String : Any]
                if d1.keys.sorted().elementsEqual(d2.keys.sorted()) {
                    print("\(plistFileName).plist both dict have same set of keys, so no need to replacement")
                }else{
                    print("\(plistFileName).plist different set of keys, so need to replacement")
                    try! fileManager.removeItem(at: URL(fileURLWithPath: path))
                    try! fileManager.copyItem(atPath: bundlePath, toPath: path)
//                    try! fileManager.replaceItemAt(URL(fileURLWithPath: path), withItemAt: URL(fileURLWithPath: bundlePath))
                }
            }
        } else {
            print("\(plistFileName).plist not found. Please, make sure it is part of the bundle.")
        }
        
        
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        print("Loaded state.plist file is --> \(String(describing: resultDictionary?.description))")
        return resultDictionary!
    }
    
    
    static func getMappedValue(dict:NSMutableDictionary?, key:String?)->AnyObject!{
        if(dict != nil){
            return dict?.value(forKey: key!) as AnyObject?
        }
        return nil
    }
    
    static func setMappedValueForKey(dict:NSMutableDictionary?, key:String?, value:AnyObject?){
        if(dict != nil){
            dict?.setValue(value, forKey: key!)
            updateAppState(dict: dict, plistFile: "sensorcoreconfig")
        }
    }
    static func updateAppState(dict:NSMutableDictionary?, plistFile:String){
        //dispatch_get_main_queue().asynchronously(execute: {
        DispatchQueue.main.async(execute: {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
            let documentsDirectory = paths.object(at: 0) as! NSString
            let path = documentsDirectory.appendingPathComponent(plistFile + ".plist")
            
            dict!.write(toFile: path, atomically: true)
            
            let resultDictionary = NSMutableDictionary(contentsOfFile: path)
            //            print("Saved \(plistFile).plist file is --> \(String(describing: resultDictionary?.description))")
            
        })
    }
    
//    
//    //Mark: notification
//    static func generateSystemNotification(message:String){
//        let time = Date().timeIntervalSince1970
//        let notifStruct:AppNotificationStruct = AppNotificationStruct(notificationId: Int64(time), originatedSource: getAppDisplayName(), originatedTime: String(time), title: getAppDisplayName(), message: message, loadingTime: String(time), loadingTimeZone: String(time), deleteOnView: 1, expiry: 12 * 60 * 60, viewCount: 0)
//        Syncer.sharedInstance.insertNotification(notifStruct: notifStruct)
//        increaseNotificationBadge()
//    }
//    static func generateSystemNotification(message:String, playSound:Bool){
//        let time = Date().timeIntervalSince1970
//        let notifStruct:AppNotificationStruct = AppNotificationStruct(notificationId: Int64(time), originatedSource: getAppDisplayName(), originatedTime: String(time), title: getAppDisplayName(), message: message, loadingTime: String(time), loadingTimeZone: String(time), deleteOnView: 1, expiry: 12 * 60 * 60, viewCount: 0)
//        Syncer.sharedInstance.insertNotification(notifStruct: notifStruct)
//        increaseNotificationBadge()
//        if playSound{
//            // create a sound ID, in this case its the tweet sound.
//            let systemSoundID: SystemSoundID = 1016
//            
//            // to play sound
//            AudioServicesPlaySystemSound (systemSoundID)
//        }
//    }
//    
//    static func increaseNotificationBadge(){
//        let userInfo = [ "offset" : 1]
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatenotification"), object: nil, userInfo: userInfo)
//        print("going to call increase notification")
//        
//    }
//    
//    static func decreaseNotificationBadge(){
//        let userInfo = [ "offset" : -1]
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatenotification"), object: nil, userInfo: userInfo)
//        
//    }
//    
    static func getInterfaces() -> [String] {
        guard let unwrappedCFArrayInterfaces = CNCopySupportedInterfaces() else {
            print("this must be a simulator, no interfaces found")
            return [""]
        }
        guard let swiftInterfaces = (unwrappedCFArrayInterfaces as NSArray) as? [String] else {
            print("System error: did not come back as array of Strings")
            return [""]
        }
        print("total interface : \(swiftInterfaces.count)")
        for interface in swiftInterfaces {
            print("Looking up SSID info for \(interface)") // en0
            guard let unwrappedCFDictionaryForInterface = CNCopyCurrentNetworkInfo(interface as CFString) else {
                print("System error: \(interface) has no information")
                return [""]
            }
            guard let SSIDDict = (unwrappedCFDictionaryForInterface as NSDictionary) as? [String: AnyObject] else {
                print("System error: interface information is not a string-keyed dictionary")
                return [""]
            }
            let bssid = SSIDDict["BSSID"] as! String
            let ssid = SSIDDict["SSID"] as! String
            print("bssid: \(bssid), ssid: \(ssid)")
            return [ssid, bssid]
            
            /*
             for d in SSIDDict.keys {
             print("\(d): \(SSIDDict[d]!)")
             }*/
        }
        return [""]
    }
    
    
//    static func connectedWiFi() -> String{
//        
//        let reachability = try! Reachability()
//        if reachability.connection == .wifi {
//            print("reachable via wifi")
//            let wifiInfo:[String] = Utils.getInterfaces()
//            if(wifiInfo.count == 2){
//                //let ssid = wifiInfo[0]
//                let bssid = wifiInfo[1]
//                if bssid.starts(with: "00:00"){
//                    return ""
//                }
//                return bssid
//            }
//        }
//        
//        //        if let reachability = try? Reachability(){
//        //            if(reachability.connection != .unavailable){
//        //                if(reachability.connection == .wifi){
//        //                    print("reachable via wifi")
//        //                    let wifiInfo:[String] = Utils.getInterfaces()
//        //                    if(wifiInfo.count == 2){
//        //                        //let ssid = wifiInfo[0]
//        //                        let bssid = wifiInfo[1]
//        //                        if bssid.starts(with: "00:00"){
//        //                            return ""
//        //                        }
//        //                        return bssid
//        //                    }
//        //                }
//        //            }
//        //        }
//        
//        return ""
//    }
//    
//    static func stringIsEmpty(checkString:String!)->Bool{
//        if let myString = checkString{
//            if myString.isEmpty{
//                return true
//            } else{
//                return false
//            }
//        } else {
//            return false
//        }
//    }
//    func currentUnixTimeUptoSec() -> Int64{
//        return Int64(NSDate().timeIntervalSince1970)
//    }
//    
//    
//    static func uploadTokenIfRequired(){
//        if let fcmStatus = Utils.getDataFromUserDefaults(key: "is_fcm_token_uploaded") as! String?{
//            if fcmStatus == "true" {
//                // no action required
//                print("fcm token uploaded, no action required")
//            }else{
//                print("fcm token will be uploaded...")
//                uploadToken()
//            }
//        }else{
//            print("This should not be reached from the code")
//        }
//        
//    }
//    
//    static func uploadToken(){
//        if let email:String = Utils.getDataFromUserDefaults(key: "email") as! String?{
//            if let fcmToken = Utils.getDataFromUserDefaults(key: "fcm_token") as! String?{
//                var deviceToken = ""
//                if let deviceTokenInStore = Utils.getDataFromUserDefaults(key: "device_token") as! String?{
//                    deviceToken = deviceTokenInStore
//                }
//                
//                var serviceUrl = Utils.getBaseUrl() + "device/fcm?email=\(email)&uuid=\(Utils.getDeviceIdentifier())&fcm_token=\(fcmToken)&device_token=\(deviceToken)"
//                serviceUrl = serviceUrl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
//                print("fcm url \(serviceUrl)")
//                Alamofire.request(serviceUrl, headers: headers).validate().responseJSON { response in
//                    switch response.result {
//                    case .success:
//                        let json = JSON(response.result.value as Any)
//                        let responseStruct = Response.responseFromJSONData(jsonData: json)
//                        print("response after object : \(responseStruct.code), \(responseStruct.message), \(serviceUrl)")
//                        if responseStruct.code == 0{
//                            Utils.saveDataToUserDefaults(data: "true", key: "is_fcm_token_uploaded")
//                        } else{
//                            Utils.saveDataToUserDefaults(data: "false", key: "is_fcm_token_uploaded")
//                        }
//                    case .failure(let error):
//                        print("error in ping: \(error.localizedDescription)")
//                        // TODO: show error label - service not available
//                        Utils.saveDataToUserDefaults(data: "false", key: "is_fcm_token_uploaded")
//                    }
//                }
//            }
//            
//        }
//        
//    }
//    
//    static func getSizeOfFiles(directory:String, fileType:String)->String{
//        let files = FCFileManager.listFilesInDirectory(atPath: directory, withExtension: fileType)
//        var bytes:Int64 = 0
//        for file in files!{
//            if let filePath: String = file as? String{
//                if FCFileManager.isFileItem(atPath: filePath) {
//                    bytes += FCFileManager.sizeOfItem(atPath: filePath) as! Int64
//                }
//            }
//        }
//        //larger than 1 MB
//        if bytes > 1024 * 1024 {
//            return String(Int64(bytes/(1024 * 1024))) + " MB"
//        }
//        if bytes > 1024{
//            return String(Int64(bytes/1024)) + " KB"
//        }
//        
//        return String(bytes) + " B"
//    }
//    
    
}



