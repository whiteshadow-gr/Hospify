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
import Fabric
import Crashlytics
import Stripe

// MARK: Class

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    // MARK: - Variables
    
    var window: UIWindow?
    private var region: CLCircularRegion? = nil
    
    /// Load the LocationManager
    lazy var locationManager: CLLocationManager! = {
        
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = MapsHelper.GetUserPreferencesAccuracy()
        locationManager.distanceFilter = MapsHelper.GetUserPreferencesDistance()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
        locationManager.disallowDeferredLocationUpdates()
        locationManager.activityType = CLActivityType.otherNavigation /* see https://developer.apple.com/reference/corelocation/clactivitytype */
        return locationManager
    }()
    
    // MARK: - App Delegate methods
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Fabric.with([Crashlytics.self])
        
        STPPaymentConfiguration.shared().publishableKey = "pk_live_IkuCnCV8N48VKdcMfbfb1Mp7"
        STPPaymentConfiguration.shared().appleMerchantIdentifier = "merchant.com.hubofallthings.rumpellocationtracker"
        
        // if app was closed by iOS (low mem, etc), then receives a location update, and respawns your app, letting it know it respawned due to a location service
        if launchOptions?[UIApplicationLaunchOptionsKey.location] != nil {
            
            self.startUpdatingLocation()
        }
        self.startUpdatingLocation()
        self.locationManager.startMonitoringSignificantLocationChanges()
        
        // change tab bar item font
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "OpenSans", size: 11)!], for: UIControlState.normal)
        
        // change bar button item font
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 17)!], for: UIControlState.normal)
        
        // define the interval for background fetch interval
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        // register for user notifications
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        
        self.window?.tintColor = Constants.Colours.AppBase
        
        let regions = self.locationManager.monitoredRegions
        
        for region in regions {
            
            self.locationManager.stopMonitoring(for: region)
        }
        
        self.locationManager.requestLocation()
        
        UINavigationBar.appearance().isOpaque = true
        UINavigationBar.appearance().barTintColor = UIColor.tealColor()
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName : UIFont(name: "OpenSans", size: 20)!]
        UIBarButtonItem.appearance()
            .setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName : UIFont(name: "OpenSans", size: 17)!], for: UIControlState.normal)
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let taskID = beginBackgroundUpdateTask()
        let syncHelper = SyncDataHelper()
        if syncHelper.CheckNextBlockToSync() == true {
            
            completionHandler(.newData)
        } else {
            
            completionHandler(.noData)
        }
        self.endBackgroundUpdateTask(taskID: taskID)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // cancel all notifications
        UIApplication.shared.cancelAllLocalNotifications()
        
        // date
        let timeInterval: TimeInterval = FutureTimeInterval.init(days: Double(3), timeType: TimeType.future).interval
        let futureDate = Date().addingTimeInterval(timeInterval) // e.g. 3 days from now
        
        // add new
        let localNotification: UILocalNotification = UILocalNotification()
        localNotification.alertAction = NSLocalizedString("sync_reminder_title", comment: "title")
        localNotification.alertBody = NSLocalizedString("sync_reminder_message", comment: "message")
        localNotification.fireDate = futureDate
        localNotification.timeZone = TimeZone.current
        localNotification.soundName = UILocalNotificationDefaultSoundName
        
        UIApplication.shared.scheduleLocalNotification(localNotification)
        
        locationManager.stopUpdatingLocation()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        locationManager.requestLocation()
        self.startUpdatingLocation()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // purge old data
        self.purgeUsingPredicate()
        self.startUpdatingLocation()
        self.endBackgroundUpdateTask(taskID: UIBackgroundTaskIdentifier.init())
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        locationManager.stopUpdatingLocation()
        _ = self.beginBackgroundUpdateTask()
    }
    
    // MARK: - oAuth handler function
    
    /*
     Callback handler oAuth
     */
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if let urlHost: String = url.host {
            
            if urlHost == Constants.Auth.LocalAuthHost {
                
                let result = KeychainHelper.GetKeychainValue(key: "logedIn")
                if (result == "expired") {
                    
                    NotificationCenter.default.post(name: Notification.Name("reauthorisedUser"), object: url)
                } else if (result == "false") {
                    
                    let notification = Notification.Name(Constants.Auth.NotificationHandlerName)
                    NotificationCenter.default.post(name: notification, object: url)
                    _ = KeychainHelper.SetKeychainValue(key: "logedIn", value: "true")
                }
            } else if urlHost == "dataplugsapphost" {
                
                let notification = Notification.Name("dataPlugMessage")
                NotificationCenter.default.post(name: notification, object: url)
            }
        }
        return true
    }
    
    // MARK: - Purge data
    
    /**
     Check if we need to purge old data. 7 Days
     */
    private func purgeUsingPredicate() -> Void {
        
        let lastWeek = Date().addingTimeInterval(FutureTimeInterval.init(days: Constants.PurgeData.OlderThan, timeType: TimeType.past).interval)
        let predicate = NSPredicate(format: "dateAdded <= %@", lastWeek as CVarArg)
        
        // use _ to get rid of result is unused warnings
        _ = RealmHelper.Purge(predicate)
    }
    
    // MARK: - Location Manager Delegate Functions
    
    /**
     The CLLocationManagerDelegate delegate
     Called when location update changes
     
     - parameter manager:   The CLLocation manager used
     - parameter locations: Array of locations
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        MapsHelper.addLocationsToDatabase(locationManager: manager, locations: locations)
        
        self.stopRegionTracking()
        
        self.region = CLCircularRegion(center: locations[locations.count - 1].coordinate, radius: 150, identifier: "UpdateCircle")
        
        self.region!.notifyOnExit = true
        locationManager.stopUpdatingLocation()
        locationManager.startMonitoring(for: region!)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        if region is CLCircularRegion {
            
            self.locationManager.requestLocation()
        }
    }
    
    func startUpdatingLocation() -> Void {
        
        /*
         If not authorised, we can ignore.
         Onve user us logged in and has accepted the authorization, this will always be true
         */
        if let manager: CLLocationManager = locationManager {
            
            if let result = KeychainHelper.GetKeychainValue(key: "trackDevice") {
                
                if result == "true" {
                    
                    manager.requestLocation()
                }
            } else {
                
                _ = KeychainHelper.SetKeychainValue(key: "trackDevice", value: "true")
                self.stopRegionTracking()
                self.locationManager.stopUpdatingLocation()
                self.locationManager = nil
                self.locationManager.stopMonitoringSignificantLocationChanges()
            }
        }
    }
    
    private func stopRegionTracking() {
        
        if self.region != nil {
            
            self.locationManager.stopMonitoring(for: self.region!)
            self.region = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        
        print("Monitoring failed for region with identifier: \(region!.identifier)")
        Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["Monitoring failed for region with identifier: " : "\(region!.identifier)"])
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Location Manager failed with the following error: \(error)")
        Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["Location Manager failed with the following error: " : "\(error)"])
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        
        if error != nil {
            
            Crashlytics.sharedInstance().recordError(error!, withAdditionalUserInfo: ["error" : error!.localizedDescription, "statusCode: " : String(describing: manager.monitoredRegions)])
        }
    }
    
    // MARK: - Background Task Functions
    
    // background task
    func beginBackgroundUpdateTask() -> UIBackgroundTaskIdentifier {
        
        return UIApplication.shared.beginBackgroundTask(expirationHandler: {})
    }
    
    func endBackgroundUpdateTask(taskID: UIBackgroundTaskIdentifier) {
        
        UIApplication.shared.endBackgroundTask(taskID)
    }
}
