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

import UIKit

// MARK: Class

// A class handling all the constant values for easy access
class Constants {
    
    // MARK: - Typealiases
    
    typealias MarketAccessTokenAlias = String
    typealias MarketDataPlugIDAlias = String
    typealias HATUsernameAlias = String
    typealias HATPasswordAlias = String
    typealias UserHATDomainAlias = String
    typealias HATRegistrationURLAlias = String
    typealias UserHATAccessTokenURLAlias = String
    typealias UserHATDomainPublicTokenURLAlias = String
    
    // MARK: - Enums
    
    /**
     The request fields for data points
     
     - Latitude: latitude
     - Longitude: longitude
     - Accuracy: accuracy
     - Timestamp: timestamp
     - allValues: An array of all the above values
     */
    enum RequestFields: String {
        
        /// Requesting Latitude
        case Latitude = "latitude"
        /// Requesting Longitude
        case Longitude = "longitude"
        /// Requesting Accuracy
        case Accuracy = "accuracy"
        /// Requesting Timestamp
        case Timestamp = "timestamp"
        
        /// Requesting all of RequestFields values in an array
        static let allValues = [Latitude, Longitude, Accuracy, Timestamp]
    }
    
    /**
     The possible notification names, stored in convenience in one place
     
     - reauthorised: reauthorised
     - dataPlug: dataPlugMessage
     - hideNewbie: hideNewbiePageViewContoller
     */
    enum NotificationNames: String {
        
        case reauthorised = "reauthorised"
        case dataPlug = "dataPlugMessage"
        case hideNewbie = "hideNewbiePageViewContoller"
    }
    
    /**
     The possible reuse identifiers of the cells
     
     - dataplug: dataPlugCell
     */
    enum CellReuseIDs: String {
        
        case dataplug = "dataPlugCell"
    }
    
    // MARK: - Structs
    
    /**
     Date formats
     */
    struct DateFormats {
        
        /// UTC format
        static let UTC: String = "yyyy-MM-dd'T'HH:mm:ssZ"
    }
    
    /**
     DataPoint Block size
     */
    struct DataPointBlockSize {
        
        /// Max block size
        static let MaxBlockSize: Int = 100
    }
    
    /**
     DataPoint sync period
     */
    struct DataSync {
        
        /// the data sync period
        static let DataSyncPeriod: UInt64 = 10
    }
    
    /**
     DataPoint purge data
     */
    struct PurgeData {
        
        /// Older than 7 days
        static let OlderThan: Double = 7
    }
    
    /**
     Colors struct
     */
    struct Colours {
        
        /// The app's basic color
        static let AppBase: UIColor = UIColor.fromRGB(0x018675)
    }
    
    /**
     Authentication struct
     */
    struct Auth {
        
        /// The name of the declared in the bundle identifier
        static let URLScheme: String = "rumpellocationtrackerapp"
        /// The name of the service, RumpelLite
        static let ServiceName: String = "RumpelLite"
        /// The name of the local authentication host, can be anything
        static let LocalAuthHost: String = "rumpellocationtrackerapphost"
        /// The notification handler name, can be anything
        static let NotificationHandlerName: String = "rumpellocationtrackerappnotificationhandler"
        /// The token name, QS parameter
        static let TokenParamName: String = "token"
    }
    
    /**
     Keychain struct
     */
    struct Keychain {
        
        /// the HAT domain key
        static let HATDomainKey: String = "user_hat_domain"
    }
    
    /**
     Request URL's struct
     */
    struct RequestUrls {
        
        /// data plugs URL
        static let AppRegistrationWithHATURL = "https://marketsquare.hubofallthings.com/api/dataplugs/"
    }
    
    /**
     The content types available
     */
    struct ContentType {
        
        /// JSON content
        static let JSON = "application/json"
        /// Text content
        static let Text = "text/plain"
    }
     
    /**
     HAT credintials for location tracking
     */
    struct HATDataPlugCredentials {
        
        /// hat username used for location data plug
        static let HAT_Username = "location"
        /// hat password used for location data plug
        static let HAT_Password = "MYl06ati0n"
        /// market data plug id used for location data plug
        static let Market_DataPlugID = "c532e122-db4a-44b8-9eaf-18989f214262"
        /// market access token used for location data plug
        static let Market_AccessToken:MarketAccessTokenAlias = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxLVZyaHVrWFh1bm9LRVwvd3p2Vmh4bm5FakdxVHc2RCs3WVZoMnBLYTdIRjJXbHdUV29MQWR3K0tEdzZrTCtkQjI2eHdEbE5sdERqTmRtRlwvVWtWM1A2ODF3TXBPSUxZbFVPaHI1WnErTT0iLCJkYXRhcGx1ZyI6ImM1MzJlMTIyLWRiNGEtNDRiOC05ZWFmLTE4OTg5ZjIxNDI2MiIsImlzcyI6ImhhdC1tYXJrZXQiLCJleHAiOjE1MTU2MDQ3NzUsImlhdCI6MTQ4NDg0NjM3NSwianRpIjoiZTBlMjIwY2VmNTMwMjllZmQ3ZDFkZWQxOTQzYzdlZWE5NWVjNWEwNGI4ZjA1MjU1MzEwNDgzYTk1N2VmYTQzZWZiMzQ5MGRhZThmMTY0M2ViOGNhNGVlOGZkNzI3ZDBiZDBhZGQyZTgzZWZkNmY4NjM2NWJiMjllYjY2NzQ3MWVhMjgwMmQ4ZTdkZWIxMzlhZDUzY2UwYzQ1ZTgxZmVmMGVjZTI5NWRkNTU0N2I2ODQzZmRiZTZlNjJmZTU1YzczYzAyYjA4MDAzM2FlMzQyMWUxZWJlMGFhOTgzNmE4MGNjZjQ0YmIxY2E1NmQ0ZjM4NWJkMzg1ZDY4ZmY0ZTIwMyJ9.bPTryrVhFa2uAMSZ6A5-Vvca7muEf8RrWoiire7K7ko"
    }
        
    /**
     The user's preferences, settings
     */
    struct Preferences {

        /// User's default accuracy
        static let UserNewDefaultAccuracy = "shared_user_new_default_accuracy"

        /// User's map accuracy
        static let MapLocationAccuracy = "shared_map_location_accuracy"
        /// User's map distance
        static let MapLocationDistance = "shared_map_location_distance"
        /// User's map deferred distance
        static let MapLocationDeferredDistance = "shared_map_location_deferred_distance"
        /// User's map deferred timeout
        static let MapLocationDeferredTimeout = "shared_map_location_deferred_timeout"
        
        /// Successful sync count
        static let SuccessfulSyncCount = "shared_successful_sync_count"
        /// Successful sync date
        static let SuccessfulSyncDate = "shared_successful_sync_date"
    }
    
    /**
     The HAT datasource will never change (not for v1 at least). It's the structure for the data held at HAT
     */
     struct HATDataSource {
        
        /// The name of the data source
        let name: String = "locations"
        /// The source of the data source
        let source: String = "iphone"
        /// The fields of the data source
        var fields: [JSONDataSourceRequestField] = [JSONDataSourceRequestField]()

        /**
         Initializer, for each field in RequestFields.allValues extracts the info and adds it to fields
         */
        init() {

            // iterate over our RequestFields enum
            for field in RequestFields.allValues {
                
                let f: JSONDataSourceRequestField = JSONDataSourceRequestField()
                
                f.name = field.rawValue
                f.fieldEnum = field
                
                fields.append(f)
            }
        }
        
        /**
         Turns the fields into a JSON object, dictionary
         
         - returns: A dictionary of <String, AnyObject>
         */
        func toJSON() -> Dictionary<String, AnyObject> {
            
            var dictionaries = [[String : String]]()

            for field: JSONDataSourceRequestField in self.fields {
                
                dictionaries.append(["name" : field.name])
            }

            // return the json as dictionary
            return [
                "name": self.name as AnyObject,
                "source": self.source as AnyObject,
                "fields": dictionaries as AnyObject
            ]
        }
    }
}
