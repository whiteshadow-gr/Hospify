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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // register for user notifications
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        /* we already have a hat_domain, ie. can skip the login screen? */
        if !Helper.TheUserHATDomain().isEmpty {
            /* Go to the map screen. */
            let nav: UINavigationController = window?.rootViewController as! UINavigationController
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc: MapViewController = storyboard.instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController
            nav.setViewControllers([vc], animated: false)
        } else {
            /* Just fall through to go to the login screen as per the storyboard. */
        }
        
        self.window?.tintColor = Constants.Colours.AppBase
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // cancel all notifications
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        // add new
        let localNotification:UILocalNotification = UILocalNotification()
        localNotification.alertAction = NSLocalizedString("sync_reminder_title", comment:  "title")
        localNotification.alertBody = NSLocalizedString("sync_reminder_message", comment:  "message")
        
        // date
        
        let timeInterval:NSTimeInterval = Helper.FutureTimeInterval.init(days: Double(3), timeType: Helper.TimeType.Future).interval
        let futureDate = NSDate().dateByAddingTimeInterval(timeInterval) // e.g. 3 days from now

        localNotification.fireDate = futureDate
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.soundName = UILocalNotificationDefaultSoundName

        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        purgeUsingPredicate()
        
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }
    
    /**
     Check if we need to purge old data. 7 Days
     */
    func purgeUsingPredicate() -> Void {
        
        let lastWeek = NSDate().dateByAddingTimeInterval(Helper.FutureTimeInterval.init(days: Constants.PurgeData.OlderThan, timeType: Helper.TimeType.Past).interval)
        let predicate = NSPredicate(format: "dateAdded <= %@", lastWeek)
        
        RealmHelper.Purge(predicate)
        
    }

   
    
}

