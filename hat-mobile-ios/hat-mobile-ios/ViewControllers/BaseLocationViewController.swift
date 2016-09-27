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

import UIKit
import CoreLocation

class BaseLocationViewController: BaseViewController, CLLocationManagerDelegate {
    
    var updateCountDelegate: UpdateCountDelegate? = nil
    var deferringUpdates:Bool = false;
    
    /// Load the LocationManager
    lazy var locationManager: CLLocationManager! = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = self.getUserPreferencesAccuracy()
        locationManager.distanceFilter = self.getUserPreferencesDistance()//ekCLDistanceFilterNone: all movements are reported... or move x metres e,g, 10.0f
        locationManager.delegate = self
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        } else {
            // Fallback on earlier versions
        }
        locationManager.requestAlwaysAuthorization()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = CLActivityType.Other /* see https://developer.apple.com/reference/corelocation/clactivitytype */
        return locationManager
    }()
    
    /**
     Start tracking
     */
    func beginLocationTracking() -> Void {
        if let manager:CLLocationManager = locationManager
        {
            manager.startUpdatingLocation()
        }
        
    }
    
    /**
     The CLLocationManagerDelegate delegate
     Called when location update changes
     
     - parameter manager:   The CLLocation manager used
     - parameter locations: Array of locations
     */
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        // clear down error display
        self.clearErrorDisplay()
        
        // get last location
        let latestLocation: CLLocation = locations[locations.count - 1]
        
        // add data
        let count = RealmHelper.AddData(Double(latestLocation.coordinate.latitude), longitude: Double(latestLocation.coordinate.longitude), accuracy: Double(latestLocation.horizontalAccuracy))
        
        //   while in foreground only
        if UIApplication.sharedApplication().applicationState == .Active {
            
            if (self.updateCountDelegate != nil) {
                self.updateCountDelegate?.onUpdateCount(count)
            }
        } else {
            //NSLog("App is backgrounded. New count is %i", count)
        }
        
        
        /**
         *  Only call one. Calling again will disable it
         defer updates until a distance or period of time
         */
        if (!deferringUpdates)
        {
            // if we are deferring, the distanceFilter = kCLDistanceFilterNone
            //locationManager.distanceFilter = kCLDistanceFilterNone
            // get distance and time settings
            let distance: CLLocationDistance = self.getUserPreferencesDeferredDistance()
            let time:NSTimeInterval = self.getUserPreferencesDeferredTimeout()
            
            manager.allowDeferredLocationUpdatesUntilTraveled(distance, timeout: time)
            
            deferringUpdates = true;
        }else{
            //locationManager.distanceFilter = self.getUserPreferencesDeferredDistance()
        }
        
    }
    
    //didFinishDeferredUpdatesWithError:
    func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?) {
        // Stop deferring updates
        self.deferringUpdates = false
        
        //self.displayError("didFinishDeferredUpdatesWithError, " + (error?.localizedDescription)!)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        self.displayError("didFailWithError, " + error.localizedDescription)
        
    }
    
    /**
     Stop any location updates.e.g.logout
     */
    func stopUpdating() -> Void {
        
        // location manager is an optinal
        if let manager:CLLocationManager = self.locationManager
        {
            manager.stopUpdatingLocation()
        }
    }
    
    /**
     Display any error to user
     Mainly for Dev
     
     
     
     - parameter description: <#description description#>
     */
    func displayError(description: String) -> Void {
        if UIApplication.sharedApplication().applicationState == .Active {
            
            if (self.updateCountDelegate != nil) {
                self.updateCountDelegate?.onUpdateError(description)
            }
        }
        
    }
    
    /**
     Clear any dispaly errors
     Mainly for dev
     
     */
    func clearErrorDisplay() -> Void {
        if UIApplication.sharedApplication().applicationState == .Active {
            
            if (self.updateCountDelegate != nil) {
                self.updateCountDelegate?.onUpdateError("")
            }
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
