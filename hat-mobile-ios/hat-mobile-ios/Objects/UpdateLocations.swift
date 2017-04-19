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

// MARK: Class

/// A class responsible for handling the gps tracking
class UpdateLocations: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Variables

    /// The deleage variable of the protocol for gps tracking
    weak var locationDelegate: UpdateLocationsDelegate?
    
    /// A singleton to always have access to
    static var shared: UpdateLocations = UpdateLocations()
    
    /// An optional function to execute after the delegate has executed
    var completion: ((CLLocation) -> Void)?
    
    // The region currently monitoring
    private var region: CLCircularRegion? = nil
    
    /// The LocationManager responsible for the settings used for gps tracking
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
    
    // MARK: - View controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.stopMonitoringAllRegions()

        UpdateLocations.shared.startUpdatingLocation()
        UpdateLocations.shared.locationManager.startMonitoringSignificantLocationChanges()
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
        
        // add locations gather to database
        MapsHelper.addLocationsToDatabase(locationManager: manager, locations: locations)
        
        // stop monitoring for regions
        UpdateLocations.shared.stopMonitoringAllRegions()
        
        // create a new region
        UpdateLocations.shared.region = CLCircularRegion(center: locations[locations.count - 1].coordinate, radius: 150, identifier: "UpdateCircle")
        UpdateLocations.shared.region!.notifyOnExit = true
        
        // call delegate method
        UpdateLocations.shared.locationDelegate?.updateLocations(locations: locations)
        
        // stop using gps and start monitoring for the new region
        locationManager.stopUpdatingLocation()
        locationManager.startMonitoring(for: region!)
        
        // if a completion was specified execute it
        if UpdateLocations.shared.completion != nil {
            
            UpdateLocations.shared.completion!(locations.last!)
            UpdateLocations.shared.completion = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        // create a new region everytime the user exits the region
        if region is CLCircularRegion {
            
            UpdateLocations.shared.locationManager.requestLocation()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        
        let message = "Monitoring failed for region with identifier: \(region!.identifier)"
        _ = CrashLoggerHelper.customErrorLog(message: message, error: error)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        let message = "Location Manager failed with the following error: \(error)"
        _ = CrashLoggerHelper.customErrorLog(message: message, error: error)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        
        if error != nil {
            
            let message = "error: \(error!.localizedDescription), status code: \(String(describing: manager.monitoredRegions))"
            _ = CrashLoggerHelper.customErrorLog(message: message, error: error!)
        }
    }
    
    // MARK: - Wrappers to enable disable tracking
    
    /**
     Start updating location
     */
    public func startUpdatingLocation() {
        
        /*
         If not authorised, we can ignore.
         Once user i    s logged in and has accepted the authorization, this will always be true
         */
        if let manager: CLLocationManager = locationManager {
            
            if let result = KeychainHelper.GetKeychainValue(key: "trackDevice") {
                
                if result == "true" {
                    
                    manager.requestLocation()
                }
            } else {
                
                _ = KeychainHelper.SetKeychainValue(key: "trackDevice", value: "true")
                UpdateLocations.shared.stopMonitoringAllRegions()
                UpdateLocations.shared.locationManager.stopUpdatingLocation()
                UpdateLocations.shared.locationManager = nil
                UpdateLocations.shared.locationManager.stopMonitoringSignificantLocationChanges()
            }
        }
    }
    
    /**
     Stop updating location
     */
    public func stopUpdatingLocation() {
        
        UpdateLocations.shared.locationManager.stopUpdatingLocation()
    }
    
    /**
     Stop monitoring ALL regions
     */
    public func stopMonitoringAllRegions() {
        
        let regions = self.locationManager.monitoredRegions
        
        for region in regions {
            
            UpdateLocations.shared.locationManager.stopMonitoring(for: region)
        }
        
        UpdateLocations.shared.region = nil
    }
    
    /**
     Start monitoring for significant, >500m, location changes
     */
    public func startMonitoringSignificantLocationChanges() {
        
        UpdateLocations.shared.locationManager.startMonitoringSignificantLocationChanges()
    }
    
    /**
     Stop monitoring for significant, >500m, location changes
     */
    public func stopMonitoringSignificantLocationChanges() {
        
        UpdateLocations.shared.locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    /**
     Request user's location
     */
    public func requestLocation() {
        
        UpdateLocations.shared.locationManager.requestLocation()
    }
    
    /**
     Resume location services as they were previously, if user had locations disabled then disabled it.
     */
    func resumeLocationServices() {
        
        let result = KeychainHelper.GetKeychainValue(key: "trackDevice")
        
        if result == "true" {
            
            UpdateLocations.shared.startUpdatingLocation()
            UpdateLocations.shared.startMonitoringSignificantLocationChanges()
            
        } else {
            
            UpdateLocations.shared.stopMonitoringAllRegions()
            UpdateLocations.shared.stopUpdatingLocation()
            UpdateLocations.shared.stopMonitoringSignificantLocationChanges()
            UpdateLocations.shared.locationManager = nil
        }
    }
    
}
