//
//  LocationData.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 22/11/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import SwiftyJSON

struct LocationData {

    var altitude: Double
    var altitudeAccuracy: Double
    //required
    var latitude: Double
    var heading: String
    //required
    var shared: Bool
    //required
    var accuracy: Double
    //required
    var longitude: Double
    var speed: Double
    
    init() {
        
        altitude = 0
        altitudeAccuracy = 0
        latitude = 0
        heading = ""
        shared = false
        accuracy = 0
        longitude = 0
        speed = 0
    }
    
    init(dict: Dictionary<String, Any>) {
        
        let tempAltitude: JSON = dict["altitude"] as! JSON
        let tempAltitudeAccuracy: JSON = dict["altitude_accuracy"] as! JSON
        let tempLatitude: JSON = dict["latitude"] as! JSON
        let tempHeading: JSON = dict["heading"] as! JSON
        let tempShared: JSON = dict["shared"] as! JSON
        let tempAccuracy: JSON = dict["accuracy"] as! JSON
        let tempLongitude: JSON = dict["longitude"] as! JSON
        let tempSpeed: JSON = dict["speed"] as! JSON
        
        altitude = 0
        altitudeAccuracy = 0
        latitude = 0
        heading = tempHeading.string!
        shared = false
        accuracy = 0
        longitude = 0
        speed = 0
        
        if tempAltitude.string! != "" {
            
            altitude = Double(tempAltitude.stringValue)!
        }
        if tempAltitudeAccuracy.string! != "" {
            
            altitudeAccuracy = Double(tempAltitudeAccuracy.stringValue)!
        }
        if tempLatitude.string! != "" {
            
            latitude = Double(tempLatitude.stringValue)!
        }
        if tempShared.string! != "" {
            
            shared = Bool(tempShared.stringValue)!
        }
        if tempAccuracy.string! != "" {
            
            accuracy = Double(tempAccuracy.stringValue)!
        }
        if tempLongitude.string! != "" {
            
            longitude = Double(tempLongitude.stringValue)!
        }
        if tempSpeed.string! != "" {
            
            speed = Double(tempSpeed.stringValue)!
        }
    }
}
