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

import RealmSwift

// MARK: Class

/// Static Realm Helper methods
class RealmHelper {
    
    // MARK: - Typealiases
    
    typealias Latitude = Double
    typealias Longitude = Double
    typealias Accuracy = Double
    
    // MARK: - Get realm
    
    /**
     Get the default Realm DB representation
     
     - returns: The default Realm object
     */
    class func GetRealm() -> Realm {
        
        // Get the default Realm
        let realm: Realm = try! Realm()
        
        return realm
    }
    
    // MARK: - Add data
    
    /**
     Adds data in form of lat/lng
     
     - parameter latitude: The latitude value of the point
     - parameter longitude: The longitude value of the point
     - parameter accuracy: The accuracy of the point
     
     - returns: current item count
     */
    class func AddData(_ latitude: Latitude, longitude: Longitude, accuracy: Accuracy) -> Int {

        // Get the default Realm
        let realm = self.GetRealm()
        
        // data
        let dataPoint = DataPoint()
        dataPoint.lat = latitude
        dataPoint.lng = longitude
        dataPoint.accuracy = accuracy
        dataPoint.dateAdded = Date()
        
        // Persist your data easily
        try! realm.write {
            
            realm.add(dataPoint)
        }
        
        // get count    
        let dataPoints = realm.objects(DataPoint.self)

        return dataPoints.count
    }
    
    // MARK: - Update realm

    /**
     Takes an array of DataPoints and updates the lastUpdated field
     
     - parameter dataPoints:  Array of DataPoints
     - parameter lastUpdated: Date of last sync
     */
    class func UpdateData(_ dataPoints: [DataPoint], lastUpdated: Date) -> Void {
        
        // Get the default Realm
        let realm = self.GetRealm()
        
        // iterate and update
        try! realm.write {
            
            // iterate over ResultSet and update
            for dataPoint:DataPoint in dataPoints {
                
                dataPoint.lastSynced = lastUpdated
            }
        }
    }
    
    // MARK: - Delete from realm
    
    /**
     Purge all data for a predicate
     
     - parameter predicate: The predicate used to filter the data
     - returns: always true if sucessful
     */
    class func Purge(_ predicate: NSPredicate?) -> Bool {
        
        // Get the default Realm
        let realm: Realm = self.GetRealm()

        try! realm.write {
            
            // check if predicate is nil, if it is delete everything
            guard let unwrappedPredicate = predicate else {
                
                realm.deleteAll()
                
                return
            }
            
            // filter the data using the predicate
            let list: Results<DataPoint> = realm.objects(DataPoint.self).filter(unwrappedPredicate)
            realm.delete(list)
        }
        
        return true
    }
    
    // MARK: - Get results from realm
    
    /**
     Gets a list of results from the current Realm DB object and filters by the predicate
     
     - parameter predicate: The predicate used to filter the data
     
     - returns: list of datapoints
     */
    class func GetResults(_ predicate: NSPredicate) -> Results<DataPoint>? {
        
        // Get the default Realm
        let realm: Realm = self.GetRealm()
        
        let sortProperties = [SortDescriptor(keyPath: "dateAdded", ascending: true)]
        
        return realm.objects(DataPoint.self).filter(predicate).sorted(by: sortProperties)
    }

    /**
     Gets the most recent DataPoint
     
     - returns: A DataPoint object
     */
    class func GetLastDataPoint() -> DataPoint! {
        
        // Get the default Realm
        let realm: Realm = self.GetRealm()
        
        return realm.objects(DataPoint.self).last
    }
}
