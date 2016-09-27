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
import MapKit

/// All Viewcontrollers ectend this class. Contain common functions
class BaseViewController: UIViewController {

    
    /**
     Get Main storyboard reference
     
     - returns: UIStoryboard
     */
    func getMainStoryboard() -> UIStoryboard {
        return UIStoryboard.init(name: "Main", bundle: nil)
    }

    
    /**
     Check the user preferences for accuracy setting
     
     - returns: <#return value description#>
     */
    func getUserPreferencesAccuracy() -> CLLocationAccuracy {
        
        let preferences = NSUserDefaults.standardUserDefaults()
        let newAccuracy:CLLocationAccuracy = preferences.objectForKey(Constants.Preferences.MapLocationAccuracy) as? CLLocationAccuracy ?? kCLLocationAccuracyBest
        
        return newAccuracy
    }
    
    /**
     Check the user preferences for distance setting
     
     - returns: <#return value description#>
     */
    func getUserPreferencesDistance() -> CLLocationDistance {
        
        let preferences = NSUserDefaults.standardUserDefaults()
        let newDistance:CLLocationDistance = preferences.objectForKey(Constants.Preferences.MapLocationDistance) as? CLLocationDistance ?? 5
        
        return newDistance
        
    }
    
    /**
     Check the user preferences for deferred distance
     
     - returns: <#return value description#>
     */
    func getUserPreferencesDeferredDistance() -> CLLocationDistance {
        
        let preferences = NSUserDefaults.standardUserDefaults()
        let newDistance:CLLocationDistance = preferences.objectForKey(Constants.Preferences.MapLocationDeferredDistance) as? CLLocationDistance ?? 10
        
        return newDistance
        
    }
    
    /**
     Check the user preferences for accuracy setting
     
     - returns: <#return value description#>
     */
    func getUserPreferencesDeferredTimeout() -> NSTimeInterval {
        
        let preferences = NSUserDefaults.standardUserDefaults()
        let newTime:NSTimeInterval = preferences.objectForKey(Constants.Preferences.MapLocationDeferredTimeout) as? Double ?? 10
        
        return newTime
        
    }
    
    /**
     Gets the last successful sync count from preferences
     
     - returns: Int
     */
    func getSuccessfulSyncCount() -> Int {
        
        let preferences = NSUserDefaults.standardUserDefaults()
        let successfulSyncCount:Int = preferences.integerForKey(Constants.Preferences.SuccessfulSyncCount) ?? 0
        
        return successfulSyncCount
    }
    
    /**
     Gets the last successful sync count from preferences
     
     - returns: The date of last successful sync. Optional
     */
    func getLastSuccessfulSyncDate() -> NSDate! {
        
        let preferences = NSUserDefaults.standardUserDefaults()
        if let successfulSyncDate:NSDate = preferences.objectForKey(Constants.Preferences.SuccessfulSyncDate) as? NSDate
        {
            return successfulSyncDate
        }
        
        return nil
    }

    
    /**
     Presents a common UI alert dialog.
     
     - parameter title:   <#title description#>
     - parameter message: <#message description#>
     */
    func presentUIAlertOK(title: String, message: String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok_label", comment:  "ok"), style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    /**
     When app entered background

     
     - parameter notification: <#notification description#>
     */
    @objc func didEnterBackgroundNotification(notification: NSNotification){
        //do stuff
        self.stopAnyTimers()
    }

    /**
     When app becomes active
     
     - parameter notification: default notification
     */
    @objc func didBecomeActiveNotification(notification: NSNotification){
        //do stuff
        if !Helper.TheUserHATDomain().isEmpty {
            self.startAnyTimers()
        }
    }

    /**
     Called from Observers when entering/leaving background

     */
    func stopAnyTimers() -> Void {
        //
    }
    
    /**
     Called from Observers when entering/leaving background
     */
    func startAnyTimers() -> Void {
        //
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
