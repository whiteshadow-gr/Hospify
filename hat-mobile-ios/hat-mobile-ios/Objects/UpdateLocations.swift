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

import MapKit
import Crashlytics

class UpdateLocations: UIViewController, CLLocationManagerDelegate {

    weak var locationDelegate: UpdateLocationsDelegate?
    
    static var shared: UpdateLocations = UpdateLocations()
    
    var completion: ((CLLocation) -> Void)?
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
        locationManager.activityType = CLActivityType.otherNavigation 
        return locationManager
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        UpdateLocations.shared.startUpdatingLocation()
        UpdateLocations.shared.locationManager.startMonitoringSignificantLocationChanges()
        
        let regions = UpdateLocations.shared.locationManager.monitoredRegions
        
        for region in regions {
            
            UpdateLocations.shared.locationManager.stopMonitoring(for: region)
        }
        
        UpdateLocations.shared.locationManager.requestLocation()
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        UpdateLocations.shared.stopRegionTracking()
        
        UpdateLocations.shared.region = CLCircularRegion(center: locations[locations.count - 1].coordinate, radius: 150, identifier: "UpdateCircle")
        
        UpdateLocations.shared.region!.notifyOnExit = true
        UpdateLocations.shared.locationDelegate?.updateLocations(locations: locations)
        locationManager.stopUpdatingLocation()
        locationManager.startMonitoring(for: region!)
        
        if UpdateLocations.shared.completion != nil {
            
            UpdateLocations.shared.completion!(locations.last!)
            UpdateLocations.shared.completion = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        if region is CLCircularRegion {
            
            UpdateLocations.shared.locationManager.requestLocation()
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
                UpdateLocations.shared.stopRegionTracking()
                UpdateLocations.shared.locationManager.stopUpdatingLocation()
                UpdateLocations.shared.locationManager = nil
                UpdateLocations.shared.locationManager.stopMonitoringSignificantLocationChanges()
            }
        }
    }
    
    private func stopRegionTracking() {
        
        if self.region != nil {
            
            UpdateLocations.shared.locationManager.stopMonitoring(for: self.region!)
            UpdateLocations.shared.region = nil
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
    
    func stopMonitoringAllRegions() {
        
        let regions = self.locationManager.monitoredRegions
        
        for region in regions {
            
            UpdateLocations.shared.locationManager.stopMonitoring(for: region)
        }
    }
    
    func startMonitoringSignificantLocationChanges() {
        
        UpdateLocations.shared.locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func requestLocation() {
        
        UpdateLocations.shared.locationManager.requestLocation()
    }
    
    func stopUpdatingLocation() {
        
        UpdateLocations.shared.locationManager.stopUpdatingLocation()
    }
    
}
