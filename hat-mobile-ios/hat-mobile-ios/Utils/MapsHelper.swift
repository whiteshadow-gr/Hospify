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

import CoreLocation

// MARK: Struct

/// A struct for working with the Maps
struct MapsHelper {
    
    // MARK: - Maps settings
    
    /**
     Check the user preferences for accuracy setting
     
     - returns: The defined accuracy set by the user
     */
    static func GetUserPreferencesAccuracy() -> CLLocationAccuracy {
        
        let preferences = UserDefaults.standard
        
        if preferences.object(forKey: Constants.Preferences.UserNewDefaultAccuracy) != nil {
            
            // already done
        } else {
            
            // if none, best or 10m we go to 100m accuracy instead
            let existingAccuracy:CLLocationAccuracy = preferences.object(forKey: Constants.Preferences.MapLocationAccuracy) as? CLLocationAccuracy ?? kCLLocationAccuracyHundredMeters
            
            if ((existingAccuracy == kCLLocationAccuracyBest) || (existingAccuracy == kCLLocationAccuracyNearestTenMeters)) {
                
                preferences.set(kCLLocationAccuracyHundredMeters, forKey: Constants.Preferences.MapLocationAccuracy)
            }
            
            // set user delta
            preferences.set("UserNewDefaultAccuracy", forKey: Constants.Preferences.UserNewDefaultAccuracy)
        }
        
        let newAccuracy:CLLocationAccuracy = preferences.object(forKey: Constants.Preferences.MapLocationAccuracy) as? CLLocationAccuracy ?? kCLLocationAccuracyHundredMeters
        
        return newAccuracy
    }
    
    /**
     Check the user preferences for distance setting
     
     - returns: The defined desired distance set by the user
     */
    static func GetUserPreferencesDistance() -> CLLocationDistance {
        
        let minValue: CLLocationDistance = 100;
        
        let preferences = UserDefaults.standard
        var newDistance: CLLocationDistance = preferences.object(forKey: Constants.Preferences.MapLocationDistance) as? CLLocationDistance ?? minValue
        
        // We will clip the lowest value up to a default, this can happen via a previous version of the app
        if newDistance < minValue {
            
            newDistance = minValue
        }
        
        return newDistance
    }
    
    /**
     Check the user preferences for deferred distance
     
     - returns: The defined desired deffered distance set by the user
     */
    static func GetUserPreferencesDeferredDistance() -> CLLocationDistance {
        
        let minValue: CLLocationDistance = 150;
        
        let preferences = UserDefaults.standard
        var newDistance: CLLocationDistance = preferences.object(forKey: Constants.Preferences.MapLocationDeferredDistance) as? CLLocationDistance ?? minValue
        
        // We will clip the lowest value up to a default, this can happen via a previous version of the app
        if newDistance < minValue {
            
            newDistance = minValue
        }
        
        return newDistance
    }
    
    /**
     Check the user preferences for accuracy setting
     
     - returns: The desired time interval
     */
    static func GetUserPreferencesDeferredTimeout() -> TimeInterval {
        
        let minValue: TimeInterval = 180
        
        let preferences = UserDefaults.standard
        var newTime: TimeInterval = preferences.object(forKey: Constants.Preferences.MapLocationDeferredTimeout) as? TimeInterval ?? minValue
        
        // We will clip the lowest value up to a default, this can happen via a previous version of the app
        if newTime < minValue {
            
            newTime = minValue
        }
        
        return newTime
    }

}
