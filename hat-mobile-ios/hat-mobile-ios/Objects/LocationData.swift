/** Copyright (C) 2016 HAT Data Exchange Ltd
 * SPDX-License-Identifier: AGPL-3.0
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * RumpelLite is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License
 * as published by the Free Software Foundation, version 3 of
 * the License.
 *
 * RumpelLite is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
 * the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General
 * Public License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
 */

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
