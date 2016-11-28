//
//  LocationData.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 22/11/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import SwiftyJSON

// MARK: Struct

/// A struct representing the location table received from JSON
struct LocationData {
    
    // MARK: - Variables

    /// the altitude the at time of creating the note. This value is optional
    var altitude: Double
    /// the altitude accuracy at the time of creating the note. This value is optional
    var altitudeAccuracy: Double
    /// the latitude at the time of creating the note
    var latitude: Double
    /// the heading at the time of creating the note. This value is optinal
    var heading: String
    /// is the location shared at the time of creating the note? This value is optional.
    var shared: Bool
    /// the accuracy at the time of creating the note
    var accuracy: Double
    /// the longitude at the time of creating the note
    var longitude: Double
    /// the speed at the time of creating the note. This value is optional
    var speed: Double
    
    // MARK: Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
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
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    init(dict: Dictionary<String, JSON>) {
        
        // init values first
        altitude = 0
        altitudeAccuracy = 0
        latitude = 0
        heading = ""
        shared = false
        accuracy = 0
        longitude = 0
        speed = 0
        
        // check for values and assign them if not empty
        if let tempAltitude: JSON = dict["altitude"] {
            
            if tempAltitude.string! != "" {
                
                altitude = Double(tempAltitude.stringValue)!
            }
        }
        
        if let tempAltitudeAccuracy: JSON = dict["altitude_accuracy"] {
            
            if tempAltitudeAccuracy.string! != "" {
                
                altitudeAccuracy = Double(tempAltitudeAccuracy.stringValue)!
            }
        }
        
        if let tempLatitude: JSON = dict["latitude"] {
            
            if tempLatitude.string! != "" {
                
                latitude = Double(tempLatitude.stringValue)!
            }
        }
        if let tempHeading: JSON = dict["heading"] {
            
            heading = tempHeading.string!
        }
        
        if let tempShared: JSON = dict["shared"]{
            
            if tempShared.string! != "" {
                
                shared = Bool(tempShared.stringValue)!
            }
        }
        if let tempAccuracy: JSON = dict["accuracy"] {
            
            if tempAccuracy.string! != "" {
                
                accuracy = Double(tempAccuracy.stringValue)!
            }
        }
        if let tempLongitude: JSON = dict["longitude"] {
            
            if tempLongitude.string! != "" {
                
                longitude = Double(tempLongitude.stringValue)!
            }
        }
        if let tempSpeed: JSON = dict["speed"]{
    
            if tempSpeed.string! != "" {
                
                speed = Double(tempSpeed.stringValue)!
            }
        }
    }
}
