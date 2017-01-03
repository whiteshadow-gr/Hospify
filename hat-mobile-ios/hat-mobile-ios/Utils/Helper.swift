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

import SwiftyJSON
import KeychainSwift
import CoreLocation

// MARK: Class

/*
 A series of static help functions
 Note: Note: define class in class to make static
 */
class Helper {
    
    // MARK: - enums
    
    /**
     JSON Result from HTTP requests
     
     - IsSuccess: A tuple containing: isSuccess: Bool, statusCode: Int?, result: JSON
     - Error: A tuple containing: error: Error, statusCode: Int?
     */
    enum ResultType {
        
        /// when the result is success. A tuple containing: isSuccess: Bool, statusCode: Int?, result: JSON
        case isSuccess(isSuccess: Bool, statusCode: Int?, result: JSON)
        /// when the result is error. A tuple containing: error: Error, statusCode: Int?
        case error(error: Error, statusCode: Int?)
    }
    
    /**
     String Result from HTTP requests
     
     - IsSuccess: A tuple containing: isSuccess: Bool, statusCode: Int?, result: String
     - Error: A tuple containing: error: Error, statusCode: Int?
     */
    enum ResultTypeString {
        
        /// when the result is success. A tuple containing: isSuccess: Bool, statusCode: Int?, result: String
        case isSuccess(isSuccess: Bool, statusCode: Int?, result: String)
        /// when the result is error. A tuple containing: error: Error, statusCode: Int?
        case error(error: Error, statusCode: Int?)
    }
    
    /**
     Used for time interval creation
     
     - future: Time interval in the future
     - past: Time interval in the past
     */
    enum TimeType {
        
        /// Time interval in the future
        case future
        /// Time interval in the past
        case past
    }
    
    /**
     Used for time interval creation on map view depending on the user's selection
     
     - none: No time period selected
     - yesterday: Time period selected, yesterday
     - today: Time period selected, today
     - lastWeek: Time period selected, last week
     */
    enum TimePeriodSelected {
        
        /// No time period selected
        case none
        /// Time period selected, yesterday
        case yesterday
        /// Time period selected, today
        case today
        /// Time period selected, last week
        case lastWeek
    }
    
    // MARK: - Structs
    
    /// A stuct to init a time interval in the future
    struct FutureTimeInterval {
        
        // the interval
        var interval: TimeInterval
        
        /**
         Custom initializer of FutureTimeInterval
         
         - parameter days: The days to add
         - parameter timeType: The time type
         */
        init(days: TimeInterval, timeType: TimeType) {
            
            var timeBase: Double = 24
            // depending on the time type do the math
            switch timeType {
                
            case .future:
                
                timeBase = abs(timeBase)
            case .past:
                
                timeBase = -abs(timeBase)
            }
            // save time interval
            self.interval = (timeBase * 3600 * days)
        }
    }
    
    // MARK: - Unsorted methods
    
    /**
     Get the Market Access Token for the iOS data plug
     
     - returns: MarketAccessToken
     */
    class func TheMarketAccessToken() -> Constants.MarketAccessTokenAlias {
        
        return Constants.HATDataPlugCredentials.Market_AccessToken
    }
    
    /**
     Get the Market Access Token for the iOS data plug
     
     - returns: MarketDataPlugID
     */
    class func TheMarketDataPlugID() -> Constants.MarketDataPlugIDAlias {
        
        return Constants.HATDataPlugCredentials.Market_DataPlugID
    }
    
    /**
     Construct the headers for the Requests
     
     - parameter xAuthToken: The xAuthToken String
     - returns: [String: String]
     */
    class func ConstructRequestHeaders(_ xAuthToken: String) -> [String: String] {
        
        let headers = ["Accept": Constants.ContentType.JSON, "Content-Type": Constants.ContentType.JSON, "X-Auth-Token": xAuthToken]

        return headers
    }
    
    /**
     Register with HAT url
     
     - parameter userHATDomain: The user's hat domain
     - returns: HATRegistrationURLAlias
     */
    class func TheAppRegistrationWithHATURL(_ userHATDomain: String) -> Constants.HATRegistrationURLAlias {
        
        // sample format
        // GET
        // https://marketsquare.hubofallthings.net/api/dataplugs/${MARKET_DATA_PLUG_ID}/connect?hat=${HAT_DOMAIN}

        if let escapedUserHATDomain:String = userHATDomain.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            
            let url:Constants.HATRegistrationURLAlias = Constants.RequestUrls.AppRegistrationWithHATURL +
                    self.TheMarketDataPlugID() + "/" + /* data plug id */
                    "connect?hat=" + escapedUserHATDomain  /* hat domain for the user */
            
            return url
        }

        return ""
    }
    
    /**
     Should be performed before each data post request as token lifetime is short.
     
     - returns: UserHATAccessTokenURLAlias
     */
    class func TheUserHATAccessTokenURL() -> Constants.UserHATAccessTokenURLAlias {
        
        // sample format
        // GET
        // https://${HAT_DOMAIN}/users/access_token?username=${HAT_USERNAME}&password=${HAT_PASSWORD}
        
        let url:Constants.UserHATAccessTokenURLAlias = "https://" + HatAccountService.TheUserHATDomain() + /* hat domain for the user */
                    "/users/access_token?username=" + HatAccountService.TheHATUsername() + "&password=" + HatAccountService.TheHATPassword()
        
        return url
    }
    
    /**
     Should be performed before each data post request as token lifetime is short.
     
     - returns: UserHATAccessTokenURLAlias
     */
    class func TheUsersAccessTokenURL() -> Constants.UserHATAccessTokenURLAlias {
        
        // sample format
        // GET
        // https://${HAT_DOMAIN}/users/access_token
        
        let url:Constants.UserHATAccessTokenURLAlias = "https://" + HatAccountService.TheUserHATDomain() + "/users/access_token"
        
        return url
    }
    
    /**
     Register with HAT url
     
     - returns: HATRegistrationURLAlias
     */
    class func TheUserHATDOmainPublicKeyURL(_ userHATDomain: String) -> Constants.UserHATDomainPublicTokenURLAlias! {
        
        // sample format
        // GET
        // https://iostesting.hubofallthings.net/publickey
        
        if let escapedUserHATDomain:String = userHATDomain.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            
            let url: Constants.UserHATDomainPublicTokenURLAlias = "https://" + escapedUserHATDomain + "/" + "publickey"
            
            return url
        }
        
        return nil
    }
    
    /**
        Check if our data source exists.
     
     - returns: String
     */
    class func TheUserHATCheckIfDataStructureExistsURL() -> String {
        
        // sample format
        // GET
        // http://${DOMAIN}/data/table?name=${NAME}&source=${SOURCE}`
        
        
        let url:String = "https://" + HatAccountService.TheUserHATDomain() + /* hat domain for the user */
                "/data/table?name=" + Constants.HATDataSource().name +
                "&source=" + Constants.HATDataSource().source
        
        return url
    }
    
    /**
     Creates a table creation URL
     
     - returns: String
     */
    class func createTableURL() -> String {
        
        // sample format
        // GET
        // http://${DOMAIN}/data/table?name=${NAME}&source=${SOURCE}`
        
        let url:String = "https://" + HatAccountService.TheUserHATDomain() + "/data/table"
        
        return url
    }
    
    class func TheUserHATCheckIfTableExistsURL(tableName: String, sourceName: String) -> String {
        
        // sample format
        // GET
        // http://${DOMAIN}/data/table?name=${NAME}&source=${SOURCE}`
        
        let url:String =
            "https://" + HatAccountService.TheUserHATDomain() + /* hat domain for the user */
                "/data/table?name=" + tableName + "&source=" + sourceName
        
        return url
    }
    
    /**
        Should be performed only if there isn’t an existing data source already.

     
     - returns: String
     */
    class func TheConfigureNewDataSourceURL() -> String {
        
        // sample format
        // POST
        // http://${HAT_DOMAIN}/data/table
        // Headers: ‘X-Auth-Token’: ${HAT_ACCESS_TOKEN}

        let url:String = "https://" + HatAccountService.TheUserHATDomain() + "/data/table"
        
        return url
    }
    
    /**
     If the datasource exists, we can get the field info using:
        http://${DOMAIN}/data/table/${TABLE_ID}`
     - returns: String
     */
    class func TheGetFieldInformationUsingTableIDURL(_ fieldID: Int) -> String {
        
        // sample format
        // POST
        // http://${HAT_DOMAIN}/data/record/values
        // Headers: ‘X-Auth-Token’: ${HAT_ACCESS_TOKEN}
        
        let url:String = "https://" + HatAccountService.TheUserHATDomain() + "/data/table/" + String(fieldID)
        
        return url
    }
    
    class func ThePOSTDataToHATURL() -> String {
        
        // sample format
        // POST
        // http://${HAT_DOMAIN}/data/table
        // Headers: ‘X-Auth-Token’: ${HAT_ACCESS_TOKEN}
        
        let url:String = "https://" + HatAccountService.TheUserHATDomain() + "/data/record/values"
        
        return url
    }

    class func getDateFromString(_ dateString : String) -> Date! {
        
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.DateFormats.UTC 
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = formatter.date(from: dateString)
        
        return date
    }
    
    class func getDateString(_ datetime : Date) -> String {
        
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.full
        formatter.timeStyle = DateFormatter.Style.medium
        formatter.timeZone = TimeZone(abbreviation: "UTC")

        let date = formatter.string(from: datetime)
        
        return date
    }
    
    class func getDateString(_ datetime : Date, format: String) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(abbreviation: "UTC")

        let date = formatter.string(from: datetime)
        
        return date
    }
    
    class func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        
        return UIColor(
            
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    /**
     Gets the friendly message for an exception
     
     - returns: String
     */
    class func ExceptionFriendlyMessage(_ errorCode: Int!, defaultMessage: String) -> String {
        
        if let errorCodeCheck:Int = errorCode {
            
            switch errorCodeCheck {
                
            case 401:
                
                return NSLocalizedString("exception_401", comment: "")
            case 400:
                
                return NSLocalizedString("exception_400", comment: "")
            case 500:
                
                return NSLocalizedString("exception_500", comment: "")
            case 504:
                
                return NSLocalizedString("exception_504", comment: "")
            default:
                
                return defaultMessage
            }
        } else {
            
            return defaultMessage
        }
    }
    
    /**
     Gets a param value from a url
     
     - returns: String or nil
     */
    class func GetQueryStringParameter(url: String?, param: String) -> String? {
        
        if let url = url, let urlComponents = NSURLComponents(string: url), let queryItems = (urlComponents.queryItems as [URLQueryItem]!) {
            
            return queryItems.filter({ (item) in item.name == param }).first?.value!
        }
        return nil
    }
    
    // MARK: - Keychain methods
    
    /**
    Set a value in the keychain
     
     - parameter String: the key
     - parameter String: the value
     
     - returns: Bool
     */
    class func SetKeychainValue(key: String, value: String) -> Bool {
        
        let keychain = KeychainSwift()
        //keychain.synchronizable = true
        if keychain.set(value, forKey: key, withAccess: .accessibleWhenUnlocked) {
            
            // Keychain item is saved successfully
            return true
        } else {
            
            //let st: OSStatus = keychain.lastResultCode
            return false
        }
    }
    
    /**
     Get a value from keychain
     
     - parameter String: the key
     
     - returns: String
     */
    class func GetKeychainValue(key: String) -> String? {
        
        let keychain = KeychainSwift()
        return keychain.get(key)
    }
    
    /**
     Clear a value from keychain
     
     - parameter String: the key
     
     - returns: String
     */
    class func ClearKeychainKey(key: String) -> Bool {
        
        let keychain = KeychainSwift()
        return keychain.delete(key)
    }
    
    // MARK: - Maps settings
    
    /**
     Check the user preferences for accuracy setting
     
     - returns: <#return value description#>
     */
    class func GetUserPreferencesAccuracy() -> CLLocationAccuracy {
        
        let preferences = UserDefaults.standard

        if preferences.object(forKey: Constants.Preferences.UserNewDefaultAccuracy) != nil {
            // already done
        } else {
            // if none, best or 10m we go to 100m accuracy instead
            let existingAccuracy:CLLocationAccuracy = preferences.object(forKey: Constants.Preferences.MapLocationAccuracy) as? CLLocationAccuracy ?? kCLLocationAccuracyHundredMeters
            
            if ((existingAccuracy == kCLLocationAccuracyBest) || (existingAccuracy == kCLLocationAccuracyNearestTenMeters)) {
                
                preferences.set(kCLLocationAccuracyHundredMeters, forKey: Constants.Preferences.MapLocationAccuracy)
            }
            
            // set user delta
            preferences.set("UserNewDefaultAccuracy", forKey: Constants.Preferences.UserNewDefaultAccuracy)
        }
        
        let newAccuracy:CLLocationAccuracy = preferences.object(forKey: Constants.Preferences.MapLocationAccuracy) as? CLLocationAccuracy ?? kCLLocationAccuracyHundredMeters
        
        return newAccuracy
    }

    /**
     Check the user preferences for distance setting
     
     - returns: <#return value description#>
     */
    class func GetUserPreferencesDistance() -> CLLocationDistance {
        
        let minValue: CLLocationDistance = 100;
        
        let preferences = UserDefaults.standard
        var newDistance: CLLocationDistance = preferences.object(forKey: Constants.Preferences.MapLocationDistance) as? CLLocationDistance ?? minValue
        
        // We will clip the lowest value up to a default, this can happen via a previous version of the app
        if newDistance < minValue {
            
            newDistance = minValue
        }
        
        return newDistance
    }
    
    /**
     Check the user preferences for deferred distance
     
     - returns: <#return value description#>
     */
    class func GetUserPreferencesDeferredDistance() -> CLLocationDistance {
        
        let minValue: CLLocationDistance = 150;

        let preferences = UserDefaults.standard
        var newDistance: CLLocationDistance = preferences.object(forKey: Constants.Preferences.MapLocationDeferredDistance) as? CLLocationDistance ?? minValue
        
        // We will clip the lowest value up to a default, this can happen via a previous version of the app
        if newDistance < minValue {
            
            newDistance = minValue
        }

        return newDistance
    }
    
    /**
     Check the user preferences for accuracy setting
     
     - returns: <#return value description#>
     */
    class func GetUserPreferencesDeferredTimeout() -> TimeInterval {
        
        let minValue: TimeInterval = 180
        
        let preferences = UserDefaults.standard
        var newTime: TimeInterval = preferences.object(forKey: Constants.Preferences.MapLocationDeferredTimeout) as? TimeInterval ?? minValue
        
        // We will clip the lowest value up to a default, this can happen via a previous version of the app
        if newTime < minValue {
            
            newTime = minValue
        }
        
        return newTime
    }
}
