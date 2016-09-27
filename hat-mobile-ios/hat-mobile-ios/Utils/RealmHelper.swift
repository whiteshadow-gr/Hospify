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

import Foundation
import RealmSwift

/// Static Realm Helper methods
class RealmHelper {
    
    typealias Latitude = Double
    typealias Longitude = Double
    typealias Accuracy = Double
    
    /**
     Get the defaylt Realm DB representation
     
     - returns: The default Realm object
     */
    class func GetRealm() -> Realm {
        // Get the default Realm
        let realm:Realm = try! Realm()
        
        return realm
    }
    
    /**
     Adds data in form of lat/lng
     
     - parameter latitude:  latitude value
     - parameter longitude: longitude value
     
     - returns: current item count
     */
    class func AddData(latitude: Latitude, longitude: Longitude, accuracy: Accuracy) -> Int
    {

        // Get the default Realm
        let realm = self.GetRealm()
        
        // data
        let dataPoint = DataPoint()
        dataPoint.lat = latitude
        dataPoint.lng = longitude
        dataPoint.accuracy = accuracy
        dataPoint.dateAdded = NSDate()
        
        // Persist your data easily
        try! realm.write {
            realm.add(dataPoint)
        }
        
        // get count    
        let dataPoints = realm.objects(DataPoint.self)

        return dataPoints.count
    }

    /**
     Takes an array of DataPoints and updates the lastUpdated field
     
     - parameter dataPoints:  Array of DataPoints
     - parameter lastUpdated: Date of last sync
     */
    class func UpdateData(dataPoints: [DataPoint], lastUpdated: NSDate) -> Void
    {
        
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

    /**
     Purge all data
     
     - returns: always true if sucessful
     */
    class func Purge() -> Bool
    {
        
        if let realm:Realm = self.GetRealm()
        {
            try! realm.write {
                realm.deleteAll()
            }
        }
        
        return true
    }
    
    
    /**
     Purge all data for a predicate
     
     - returns: always true if sucessful
     */
    class func Purge(predicate: NSPredicate) -> Bool
    {
        if let realm:Realm = self.GetRealm()
        {
            if let list:Results<DataPoint> = realm.objects(DataPoint.self).filter(predicate)
            {
                try! realm.write {
                    realm.delete(list)
                }
            }
            
        }
        
        return true
    }
    
    /**
     Gets a list of results from the current Realm DB object and filters by the predicate
     
     - parameter predicate: The predicate used to filter the data
     
     - returns: list of datapoints
     */
    class func GetResults(predicate: NSPredicate) -> Results<DataPoint>?
    {
        if let realm:Realm = self.GetRealm()
        {
            let sortProperties = [SortDescriptor(property: "dateAdded", ascending: true)]
            return realm.objects(DataPoint.self).filter(predicate).sorted(sortProperties)
        }
    }

    /**
     Gets the most recent DataPoint
     
     - returns: <#return value description#>
     */
    class func GetLastDataPoint() -> DataPoint!
    {
        if let realm:Realm = self.GetRealm()
        {
            return realm.objects(DataPoint.self).last
        }
    }
    
    
    
}
