//
//  KeepAliveByLocationManager.swift
//  cimontemplate
//
//  Created by Afzal Hossain on 8/9/17.
//  Copyright © 2017 Afzal Hossain. All rights reserved.
//

import Foundation
import CoreLocation

class KeepAliveByLocationManager: NSObject, CLLocationManagerDelegate{
    
    static let sharedInstance = KeepAliveByLocationManager()
    var locationManager: CLLocationManager?
    
    override init(){
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.distanceFilter = 10000
        NSLog("%@", "location manager initiated...")
    }
    
    func startLocationToKeepAlive(){
        locationManager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("location update from test thread, count:\(locations.count), time:\(NSDate())")
        //scheduleNotification(interval: 0, bodyText: "get location data \(NSDate())", actionText: "get location data")
        for location in locations{
            print("location from significant change, latitude:\(location.coordinate.latitude), longitude:\(location.coordinate.longitude), accuracy:\(location.horizontalAccuracy), \(NSDate())")
            //NSLog("%@", "keep-----alive-------, latitude:\(location.coordinate.latitude), longitude:\(location.coordinate.longitude), time remaining:\(UIApplication.shared.backgroundTimeRemaining), accuracy:\(location.horizontalAccuracy)")
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location failure from test thread \(NSDate())")
        NSLog("%@", "location failure from test thread \(NSDate())")
        //logw(text: "error, \(Utils.currentUnixTime()),location_error_alive,\(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedAlways {
            //do nothing, expected
            //logw(text: "info,\(Utils.currentUnixTime()),location_premission,permission is set to always")
        } else{
            //logw(text: "error,\(Utils.currentUnixTime()),location_permission,permission not set to always")
        }
    }
    
}

