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
class UpdateLocations: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Variables
    
    /// The delegate variable of the protocol for gps tracking
    weak var locationDelegate: UpdateLocationsDelegate?
    
    /// A singleton to always have access to
    static let shared: UpdateLocations = UpdateLocations()
    
    /// An optional function to execute after the delegate has executed
    var completion: ((CLLocation) -> Void)?
    
    // The region currently monitoring
    private var region: CLCircularRegion? = nil
    
    /// The LocationManager responsible for the settings used for gps tracking
    var locationManager: CLLocationManager? = {
        
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = MapsHelper.GetUserPreferencesAccuracy()
        locationManager.distanceFilter = MapsHelper.GetUserPreferencesDistance()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
        locationManager.disallowDeferredLocationUpdates()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = CLActivityType.otherNavigation
        return locationManager
    }()
    
    // MARK: - Initialiser
    
    override init() {
        
        super.init()
        
        self.initLocationManager()
        
        locationManager?.delegate = self
        
        self.resumeLocationServices()
    }
    
    private func initLocationManager() {
        
        if locationManager == nil {
            
            let locationManager = CLLocationManager()
            locationManager.desiredAccuracy = MapsHelper.GetUserPreferencesAccuracy()
            locationManager.distanceFilter = MapsHelper.GetUserPreferencesDistance()
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.requestAlwaysAuthorization()
            locationManager.disallowDeferredLocationUpdates()
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.activityType = CLActivityType.otherNavigation
        }
    }
    
    // MARK: - Location Manager Delegate Functions
    
    /**
     The CLLocationManagerDelegate delegate
     Called when location update changes
     
     - parameter manager:   The CLLocation manager used
     - parameter locations: Array of locations
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.initLocationManager()

        // add locations gather to database
        MapsHelper.addLocationsToDatabase(locationManager: manager, locations: locations)
        
        // stop monitoring for regions
        self.stopMonitoringAllRegions()
        
        // create a new region
        self.region = CLCircularRegion(center: locations[locations.count - 1].coordinate, radius: 150, identifier: "UpdateCircle")
        self.region!.notifyOnExit = true
        
        // call delegate method
        self.locationDelegate?.updateLocations(locations: locations)
        
        // stop using gps and start monitoring for the new region
        self.locationManager?.stopUpdatingLocation()
        self.locationManager?.startMonitoring(for: region!)
        
        // if a completion was specified execute it
        if self.completion != nil {
            
            self.completion!(locations.last!)
            self.completion = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        self.initLocationManager()

        // create a new region everytime the user exits the region
        if region is CLCircularRegion {
            
            self.locationManager?.requestLocation()
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
        
        self.initLocationManager()

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
                
                _ = KeychainHelper.SetKeychainValue(key: "trackDevice", value: "false")
                self.stopMonitoringAllRegions()
                self.locationManager?.stopUpdatingLocation()
                self.locationManager = nil
                self.locationManager?.stopMonitoringSignificantLocationChanges()
            }
        }
    }
    
    /**
     Stop updating location
     */
    public func stopUpdatingLocation() {
        
        self.initLocationManager()

        self.locationManager?.stopUpdatingLocation()
    }
    
    /**
     Stop monitoring ALL regions
     */
    public func stopMonitoringAllRegions() {
        
        self.initLocationManager()

        if let regions = self.locationManager?.monitoredRegions {
            
            for region in regions {
                
                self.locationManager?.stopMonitoring(for: region)
            }
        }
    
        self.region = nil
    }
    
    /**
     Start monitoring for significant, >500m, location changes
     */
    public func startMonitoringSignificantLocationChanges() {
        
        self.initLocationManager()

        self.locationManager?.startMonitoringSignificantLocationChanges()
    }
    
    /**
     Stop monitoring for significant, >500m, location changes
     */
    public func stopMonitoringSignificantLocationChanges() {
        
        self.initLocationManager()

        self.locationManager?.stopMonitoringSignificantLocationChanges()
    }
    
    /**
     Request user's location
     */
    public func requestLocation() {
        
        self.initLocationManager()

        self.locationManager?.requestLocation()
    }
    
    /**
     Resume location services as they were previously, if user had locations disabled then disabled it.
     */
    func resumeLocationServices() {
        
        self.initLocationManager()

        let result = KeychainHelper.GetKeychainValue(key: "trackDevice")
        
        if result == "true" {
            
            self.locationManager?.requestAlwaysAuthorization()
            self.locationManager?.startUpdatingLocation()
            self.locationManager?.startMonitoringSignificantLocationChanges()
            self.locationManager?.requestLocation()
        } else {
            
            self.stopMonitoringAllRegions()
            self.locationManager?.stopUpdatingLocation()
            self.locationManager?.stopMonitoringSignificantLocationChanges()
            self.locationManager = nil
        }
    }
    
}
