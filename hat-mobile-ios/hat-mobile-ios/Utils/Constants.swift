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

import SwiftyJSON

class Constants  {
    
    typealias MarketAccessTokenAlias = String
    typealias MarketDataPlugIDAlias = String
    typealias HATUsernameAlias = String
    typealias HATPasswordAlias = String
    typealias UserHATDomainAlias = String
    typealias HATRegistrationURLAlias = String
    typealias UserHATAccessTokenURLAlias = String
    typealias UserHATDomainPublicTokenURLAlias = String
    
    /**
     *  Date formats
     */
    struct DateFormats {
        
        // UTC format
        static let UTC:String = "yyyy-MM-dd'T'HH:mm:ssZ"
    }
    
    /**
     *  DataPoint Block size
     */
    struct DataPointBlockSize {
        
        static let MaxBlockSize:Int = 100
    }
    
    /**
     *  DataPoint Block size
     */
    struct DataSync {
        
        static let DataSyncPeriod:UInt64 = 10
    }
    
    /**
     *  DataPoint Block size
     */
    struct PurgeData {
        
        static let OlderThan:Double = 7
    }
    
    /**
     *  DataPoint Block size
     */
    struct Colours {
        
        static let AppBase:UIColor = UIColor.fromRGB(0x018675)
    }
    
    /**
     *  DataPoint Block size
     */
    struct Auth {
        
        static let URLScheme:String = "rumpellocationtrackerapp" // this is delcared in our url schemes info.list
        static let ServiceName:String = "RumpelLite" // the service name
        static let LocalAuthHost:String = "rumpellocationtrackerapphost" // this can be anything
        static let NotificationHandlerName:String = "rumpellocationtrackerappnotificationhandler" // this can be anything
        static let TokenParamName:String = "token" // QS param
    }
    
    /**
     *  Keychain. HATDomain: String value
     */
    struct Keychain {
        
        // UTC format
        static let HATDomainKey:String = "user_hat_domain"
    }
    
    
    // the request urls
    struct RequestUrls {
        
        // Check upload privs against MarketSquare
        static let AppRegistrationWithHATURL = "https://marketsquare.hubofallthings.com/api/dataplugs/"
    }
    
    struct ContentType {
        
        static let JSON = "application/json"
        static let Text = "text/plain"
        
    }
     
    // the HAT data-plug credentials
    struct HATDataPlugCredentials {
        
        // hat username
        static let HAT_Username = "location"
        // hat password
        static let HAT_Password = "MYl06ati0n"
        // market data plug id
        static let Market_DataPlugID = "c532e122-db4a-44b8-9eaf-18989f214262"
        // market access token
        static let Market_AccessToken:MarketAccessTokenAlias = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxLUw2Vlphd0JWSG1oU2FPc0NxdktMTnFLTEUrREVvN2M2VWxnSGZVVTJMQW9PSG9MdVRoQ1VcL05Nc0dVR0hYVVFWTjUwVnE2MkxTUjBFeDVaNWNqdjhXaWk3Y25WdFNrcjJHZERobnNBPSIsImRhdGFwbHVnIjoiYjY2NzNlNDYtOTI0Ni00MTM1LTkwNWUtYzI3NWUwMWU2YjVkIiwiaXNzIjoiaGF0LW1hcmtldCIsImV4cCI6MTUxNTU4NzkyOCwiaWF0IjoxNDg0ODI5NTI4LCJqdGkiOiI5NDU0MzAwMGE0ODBmN2FjMzdjOTM0NGVjZGQ0YTZiZjBkOWIzNzVmNWM3NGM0MWJlYmZjZjAwMTE0YjA0ZGY3NGViN2I5MjY1MjFkNmUwZTRjNDM4NGY3YmMxYWM1NDExYjdjN2JkZDBkNjUwYmQwOTVlYTZiNzc2MzE5MzE2MzNkZGY2MjVkMjY1NWE3N2NmYjczM2QzNGQwMDFmNTU4MDE4OTU5Zjc3ZGYxYzM5NTdhYTlkNDg0NDkzOThhZGFhMGY3OWY1NGUyNmZiN2MyMzMxZmE1YTEwMDA3YTM1NGFmN2EwNTIyOGM5NzI4OGI2NGU2MGJmY2UwYzBlOTllIn0.YHxs80oUdMvTJ1xFcryqX5xONMgPXt3Q3FE9ZwFJp4k"
    }
        
    /**
     *  The user token
     */
    struct Preferences {

        // new type 1
        static let UserNewDelta1 = "shared_user_new_delta_1"
        static let UserNewDefaultAccuracy = "shared_user_new_default_accuracy"

        // map
        static let MapLocationAccuracy = "shared_map_location_accuracy"
        static let MapLocationDistance = "shared_map_location_distance"
        static let MapLocationDeferredDistance = "shared_map_location_deferred_distance"
        static let MapLocationDeferredTimeout = "shared_map_location_deferred_timeout"
        
        // sync
        static let SuccessfulSyncCount = "shared_successful_sync_count"
        static let SuccessfulSyncDate = "shared_successful_sync_date"
    }
    
    /// An enum for creating field requests. We use this to iterate over
    enum RequestFields: String {
        
        case Latitude = "latitude"
        case Longitude = "longitude"
        case Accuracy = "accuracy"
        case Timestamp = "timestamp"
        
        static let allValues = [Latitude, Longitude, Accuracy, Timestamp]
    }
    
    /**
     *  The HAT datasource will never change (not for v1 at least). It's the structure for the data held at HAT
     */
     struct HATDataSource {
        
        let name: String = "locations"
        let source: String = "iphone"
        var fields: [JSONDataSourceRequestField] = [JSONDataSourceRequestField]()

        init() {

            // iterate over our RequestFields enum
            for field in RequestFields.allValues{
                let f: JSONDataSourceRequestField = JSONDataSourceRequestField()
                f.name = field.rawValue
                f.fieldEnum = field
                fields.append(f)
            }
            
        }
        
        func toJSON() -> Dictionary<String, AnyObject> {
            
            var dictionaries = [[String: String]]()

            for field:JSONDataSourceRequestField in self.fields {
                
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
