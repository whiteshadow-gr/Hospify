/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import SwiftyJSON

// MARK: Struct

/// A struct representing the location table received from JSON
class HATNotesLocationData: Comparable {
    
    // MARK: - Comparable protocol
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: HATNotesLocationData, rhs: HATNotesLocationData) -> Bool {
        
        return (lhs.altitude == rhs.altitude && lhs.altitudeAccuracy == rhs.altitudeAccuracy && lhs.latitude == rhs.latitude
            && lhs.accuracy == rhs.accuracy && lhs.longitude == rhs.longitude && lhs.speed == rhs.speed && lhs.heading == rhs.heading && lhs.shared == rhs.shared)
    }
    
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    ///
    /// This function is the only requirement of the `Comparable` protocol. The
    /// remainder of the relational operator functions are implemented by the
    /// standard library for any type that conforms to `Comparable`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func <(lhs: HATNotesLocationData, rhs: HATNotesLocationData) -> Bool {
        
        return (lhs.latitude < rhs.latitude && lhs.longitude < rhs.longitude)
    }
    
    // MARK: - Variables

    /// the altitude the at time of creating the note. This value is optional
    var altitude: Double
    /// the altitude accuracy at the time of creating the note. This value is optional
    var altitudeAccuracy: Double
    /// the latitude at the time of creating the note
    var latitude: Double
    /// the accuracy at the time of creating the note
    var accuracy: Double
    /// the longitude at the time of creating the note
    var longitude: Double
    /// the speed at the time of creating the note. This value is optional
    var speed: Double
    
    /// the heading at the time of creating the note. This value is optinal
    var heading: String
    
    /// is the location shared at the time of creating the note? This value is optional.
    var shared: Bool
    
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
    convenience init(dict: Dictionary<String, JSON>) {
        
        // init values first
        self.init()
        
        // check for values and assign them if not empty
        if let tempAltitude = dict["altitude"]?.string {
            
            if tempAltitude != "" {
                
                if let doubleNumberAltitute = Double(tempAltitude) {
                    
                    altitude = doubleNumberAltitute
                }
            }
        }
        
        if let tempAltitudeAccuracy = dict["altitude_accuracy"]?.string {
            
            if tempAltitudeAccuracy != "" {
                
                if let doubleNumberAltitudeAccuracy = Double(tempAltitudeAccuracy) {
                    
                    altitudeAccuracy = doubleNumberAltitudeAccuracy
                }
            }
        }
        
        if let tempLatitude = dict["latitude"]?.string {
            
            if tempLatitude != "" {
                
                if let doubleNumberLatitude = Double(tempLatitude) {
                    
                    latitude = doubleNumberLatitude
                }
            }
        }
        if let tempHeading = dict["heading"]?.string {
            
            heading = tempHeading
        }
        
        if let tempShared = dict["shared"]?.string {
            
            if tempShared != "" {
                
                if let boolShared = Bool(tempShared) {
                    
                    shared = boolShared
                }
            }
        }
        if let tempAccuracy = dict["accuracy"]?.string {
            
            if tempAccuracy != "" {
                
                if let doubleNumberAccuracy = Double(tempAccuracy) {
                    
                    accuracy = doubleNumberAccuracy
                }
            }
        }
        if let tempLongitude = dict["longitude"]?.string {
            
            if tempLongitude != "" {
                
                if let doubleNumberLongitude = Double(tempLongitude) {
                    
                    longitude = doubleNumberLongitude
                }
            }
        }
        if let tempSpeed = dict["speed"]?.string {
    
            if tempSpeed != "" {
                
                if let doubleNumberSpeed = Double(tempSpeed) {
                    
                    speed = doubleNumberSpeed
                }
            }
        }
    }
}
