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
        static let AppBase:UIColor = Helper.UIColorFromRGB(0x018675)
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
        static let Market_AccessToken:MarketAccessTokenAlias = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyLVU5MDgrR2RTY1NYMnVadmMyXC9iNjFGdGo5Rk9ZNEU4enhHYjlLalZhYTc3NHpEdk51Rm1GM1hZRHlQeG01ckJpOEtUeWFiajZjdTNORlo2UG5ia2tsU09ITVJmZ1h4QkNZdUdmYlhZPSIsImRhdGFwbHVnIjoiYzUzMmUxMjItZGI0YS00NGI4LTllYWYtMTg5ODlmMjE0MjYyIiwiaXNzIjoiaGF0LW1hcmtldCIsImV4cCI6MTUwMjgwMTE5NywiaWF0IjoxNDcyMDQyNzk3LCJqdGkiOiI3ZmRiNWFjYjc2ZTJjMjFhNWZlNGI2MTgzMWViMjI5NDFiNzcyNGNiZDY4OTFjOWM5MWE4MzY4ZmQ4ODA4MmE3MzIxMzMzMDJjYzVkNmZmNGU4MzZhYWE0N2VkZGU4MGE1OWEzZjFmZmU2MGFhMWRhZGU5ZGQ2ZTc2MGM0NGEyNjVkNjAzYjcyNjZlOGNmZmNmYjQ5YWU2OTJmZDE4NjE4N2UwNTNhMzYwYmNjOTZhMTBlMGRlNDMyZGZhZWIzNmEzZTY5MmEwMTY4ZTkwMzRhZGJjODQ1NWEyYzMzNjEyMGM0ZmJmMjg4OTYyMzliZWEwNmEyZTRjZTU0MzgwNjQzIn0.95U3GDK-Vy9aLnv6ouOO87cLuXYRAsGPu_uGQRCuRnc"
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
                let f:JSONDataSourceRequestField = JSONDataSourceRequestField()
                f.name = field.rawValue
                f.fieldEnum = field
                fields.append(f)
            }
            
        }
        
        func toJSON() -> Dictionary<String, AnyObject> {
            
            var dictionaries = [[String: String]]()

            for field:JSONDataSourceRequestField in self.fields{
                dictionaries.append(["name" : field.name])
            }

            // return the json as dictionary
            return [
                "name": self.name as AnyObject,
                "source": self.source as AnyObject,
                "fields": 
                    dictionaries as AnyObject
                
            ]
        }

    }
    

    
}
