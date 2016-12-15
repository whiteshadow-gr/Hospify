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

/*
 A series of static help functions
 Note: Note: define class in class to make static
 */
class Helper
{
    
    /**
     Result from HTTP requests
     
     - IsSuccess: <#IsSuccess description#>
     - Error:     <#Error description#>
     */
    enum ResultType {
        case isSuccess(isSuccess: Bool, statusCode: Int?, result: JSON)
        case error(error: Error, statusCode: Int?)
    }
    
    enum ResultTypeString {
        case isSuccess(isSuccess: Bool, statusCode: Int?, result: String)
        case error(error: Error, statusCode: Int?)
    }
    
    /**
     Used for tyime interval creation
     
     - Future: <#Future description#>
     - Past:   <#Past description#>
     */
    enum TimeType {
        case future
        case past
    }
    
    enum TimePeriodSelected {
        case none
        case yesyerday
        case today
        case lastWeek
    }
    /**
     Trim a given String
     
     - parameter string: the String to trim
     
     - returns: trimmed String
     */
    class func TrimString(_ string: String) -> String
    {
        return string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
    }
    
    struct FutureTimeInterval {
        var interval: TimeInterval
        
        init(days: TimeInterval, timeType: TimeType) {
            var timeBase:Double = 24
            switch timeType {
            case .future:
                timeBase = abs(timeBase)
                break;
            case .past:
                timeBase = -abs(timeBase)
                break;
            }
            self.interval = (timeBase * 3600 * days)
        }
    }
    
    /**
     *  Whether we are in emulator or not
     */
    struct Platform {
        static let isSimulator: Bool = {
            var isSim = false
            #if arch(i386) || arch(x86_64)
                isSim = true
            #endif
            return isSim
        }()
    }

    /**
     Takes a NSDate and returns a string of time ago
     
     - parameter date: NSDate object
     
     - returns: a formatted string of time-ago
     */
    class func TimeAgoSinceDate(_ date: Date) -> String{
        
        let calendar = Calendar.current
        let now = Date()
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
    
        if (components.year! >= 2) {
            return NSLocalizedString("Last year", comment: "")
        } else if (components.month! >= 2) {
            return String.localizedStringWithFormat(NSLocalizedString("%d months ago", comment: ""), components.month!)
        } else if (components.weekOfYear! >= 1){
            return NSLocalizedString("A week ago", comment: "")
        } else if (components.day! >= 2) {
            return String.localizedStringWithFormat(NSLocalizedString("%d days ago", comment: ""), components.day!)
        } else if (components.day! >= 1){
            return NSLocalizedString("A day ago", comment: "")
        } else if (components.hour! >= 2) {
            return String.localizedStringWithFormat(NSLocalizedString("%d hours ago", comment: ""), components.hour!)
        } else if (components.hour! >= 1){
            return NSLocalizedString("An hour ago", comment: "")
        } else if (components.minute! >= 2) {
            return String.localizedStringWithFormat(NSLocalizedString("%d minutes ago", comment: ""), components.minute!)
        } else if (components.minute! >= 1){
            return NSLocalizedString("A minute ago", comment: "")
        } else if (components.second! >= 3) {
            return String.localizedStringWithFormat(NSLocalizedString("%d seconds ago", comment: ""), components.second!)
        } else {
            return NSLocalizedString("Just now", comment: "")
        }
        
    }
    
    /**
     Get the Market Access Token for the iOS data plug
     
     - returns: MarketAccessToken
     */
    class func TheMarketAccessToken() -> Constants.MarketAccessTokenAlias
    {
        return Constants.HATDataPlugCredentials.Market_AccessToken
    }
    
    /**
     Get the Market Access Token for the iOS data plug
     
     - returns: MarketDataPlugID
     */
    class func TheMarketDataPlugID() -> Constants.MarketDataPlugIDAlias
    {
        return Constants.HATDataPlugCredentials.Market_DataPlugID
    }
    
    /**
     Get the Market Access Token for the iOS data plug
     
     - returns: HATUsername
     */
    class func TheHATUsername() -> Constants.HATUsernameAlias
    {
        return Constants.HATDataPlugCredentials.HAT_Username
    }
    
    /**
     Get the Market Access Token for the iOS data plug
     
     - returns: HATPassword
     */
    class func TheHATPassword() -> Constants.HATPasswordAlias
    {
        return Constants.HATDataPlugCredentials.HAT_Password
    }
    
    /**
     Get the Market Access Token for the iOS data plug
     
     - returns: UserHATDomainAlias
     */
    class func TheUserHATDomain() -> Constants.UserHATDomainAlias
    {
        
        if let hatDomain = GetKeychainValue(key: Constants.Keychain.HATDomainKey)
        {
            return hatDomain;
        }
        
        return ""
    }
    
    /**
     Construct the headres for the Requests
     
     - parameter xAuthToken: <#xAuthToken description#>
     
     - returns: [String: String]
     */
    class func ConstructRequestHeaders(_ xAuthToken: String) -> [String: String] {
        
        let headers = ["Accept": Constants.ContentType.JSON, "Content-Type": Constants.ContentType.JSON, "X-Auth-Token": xAuthToken]

        return headers
    }
    
    /**
     Register with HAT url
     
     - returns: HATRegistrationURLAlias
     */
    class func TheAppRegistrationWithHATURL(_ userHATDomain: String) -> Constants.HATRegistrationURLAlias
    {
        // sample format
        // GET
        // https://marketsquare.hubofallthings.net/api/dataplugs/${MARKET_DATA_PLUG_ID}/connect?hat=${HAT_DOMAIN}

        if let escapedUserHATDomain:String = userHATDomain.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        {
            let url:Constants.HATRegistrationURLAlias =
                Constants.RequestUrls.AppRegistrationWithHATURL +
                    self.TheMarketDataPlugID() + "/" + /* data plug id */
                    "connect?hat=" +
                    escapedUserHATDomain  /* hat domain for the user */
            
            return url

        }

        return ""
    }
    
    
    /**
     Should be performed before each data post request as token lifetime is short.
     
     - returns: UserHATAccessTokenURLAlias
     */
    class func TheUserHATAccessTokenURL() -> Constants.UserHATAccessTokenURLAlias
    {
        // sample format
        // GET
        // https://${HAT_DOMAIN}/users/access_token?username=${HAT_USERNAME}&password=${HAT_PASSWORD}
        
        let url:Constants.UserHATAccessTokenURLAlias =
                "https://" +
                    self.TheUserHATDomain() + /* hat domain for the user */
                    "/users/access_token?username=" +
                    self.TheHATUsername() +
                    "&password=" +
                    self.TheHATPassword()
        
        return url
    }
    
    /**
     Should be performed before each data post request as token lifetime is short.
     
     - returns: UserHATAccessTokenURLAlias
     */
    class func TheUsersAccessTokenURL() -> Constants.UserHATAccessTokenURLAlias
    {
        // sample format
        // GET
        // https://${HAT_DOMAIN}/users/access_token
        
        let url:Constants.UserHATAccessTokenURLAlias =
            "https://" +
                self.TheUserHATDomain() + /* hat domain for the user */
                "/users/access_token"
        
        return url
    }
    
    
    /**
     Register with HAT url
     
     - returns: HATRegistrationURLAlias
     */
    class func TheUserHATDOmainPublicKeyURL(_ userHATDomain: String) -> Constants.UserHATDomainPublicTokenURLAlias!
    {
        // sample format
        // GET
        // https://iostesting.hubofallthings.net/publickey
        
        if let escapedUserHATDomain:String = userHATDomain.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        {
            let url:Constants.UserHATDomainPublicTokenURLAlias =
                "https://" +
                    escapedUserHATDomain + "/" + /* hat domain */
                    "publickey"
            
            return url
            
        }
        
        return nil
    }
    
    
    
    /**
        Check if our data source exists.
     
     - returns: String
     */
    class func TheUserHATCheckIfDataStructureExistsURL() -> String
    {
        // sample format
        // GET
        // http://${DOMAIN}/data/table?name=${NAME}&source=${SOURCE}`
        
        
        let url:String =
            "https://" +
                self.TheUserHATDomain() + /* hat domain for the user */
                "/data/table?name=" +
                Constants.HATDataSource().name +
                "&source=" +
                Constants.HATDataSource().source
        
        return url
    }
    
    /**
     Creates a table creation URL
     
     - returns: String
     */
    class func createTableURL() -> String
    {
        // sample format
        // GET
        // http://${DOMAIN}/data/table?name=${NAME}&source=${SOURCE}`
        
        
        let url:String =
            "https://" +
                self.TheUserHATDomain() + /* hat domain for the user */
                "/data/table"
        
        return url
    }
    
    class func TheUserHATCheckIfTableExistsURL(tableName: String, sourceName: String) -> String
    {
        // sample format
        // GET
        // http://${DOMAIN}/data/table?name=${NAME}&source=${SOURCE}`
        
        
        let url:String =
            "https://" +
                self.TheUserHATDomain() + /* hat domain for the user */
                "/data/table?name=" +
                tableName +
                "&source=" +
                sourceName
        
        return url
    }


    
    
    /**
        Should be performed only if there isn’t an existing data source already.

     
     - returns: String
     */
    class func TheConfigureNewDataSourceURL() -> String
    {
        // sample format
        // POST
        // http://${HAT_DOMAIN}/data/table
        // Headers: ‘X-Auth-Token’: ${HAT_ACCESS_TOKEN}

        let url:String =
                "https://" +
                    self.TheUserHATDomain() + /* hat domain for the user */
                    "/data/table"
        
        return url
    }
   
    
    /**
     If the datasource exists, we can get the field info using:
        http://${DOMAIN}/data/table/${TABLE_ID}`
     - returns: String
     */
    class func TheGetFieldInformationUsingTableIDURL(_ fieldID: Int) -> String
    {
        // sample format
        // POST
        // http://${HAT_DOMAIN}/data/record/values
        // Headers: ‘X-Auth-Token’: ${HAT_ACCESS_TOKEN}
        
        let url:String =
            "https://" +
                self.TheUserHATDomain() + /* hat domain for the user */
                "/data/table/" +
                String(fieldID)
        
        return url
    }
    
    class func ThePOSTDataToHATURL() -> String
    {
        // sample format
        // POST
        // http://${HAT_DOMAIN}/data/table
        // Headers: ‘X-Auth-Token’: ${HAT_ACCESS_TOKEN}
        
        let url:String =
            "https://" +
                self.TheUserHATDomain() + /* hat domain for the user */
                "/data/record/values"
        
        return url
    }

    class func getDateFromString(_ dateString : String) -> Date!
    {
        
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.DateFormats.UTC 
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = formatter.date(from: dateString)
        
        return date
    }
    
    class func getDateString(_ datetime : Date) -> String
    {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.full
        formatter.timeStyle = DateFormatter.Style.medium
        formatter.timeZone = TimeZone(abbreviation: "UTC")

        let date = formatter.string(from: datetime)
        
        return date
    }
    
    class func getDateString(_ datetime : Date, format: String) -> String
    {
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
        
        if let errorCodeCheck:Int = errorCode{
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
        }
        else
        {
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
    
    
    /**
     Check the user preferences for accuracy setting
     
     - returns: <#return value description#>
     */
    class func GetUserPreferencesAccuracy() -> CLLocationAccuracy {
        
        let preferences = UserDefaults.standard

        if preferences.object(forKey: Constants.Preferences.UserNewDefaultAccuracy) != nil {
            // already done
        }else{
            // if none, best or 10m we go to 100m accuracy instead
            let existingAccuracy:CLLocationAccuracy = preferences.object(forKey: Constants.Preferences.MapLocationAccuracy) as? CLLocationAccuracy ?? kCLLocationAccuracyHundredMeters
            
            if ((existingAccuracy == kCLLocationAccuracyBest) || (existingAccuracy == kCLLocationAccuracyNearestTenMeters))
            {
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
        
        let minValue:CLLocationDistance = 100;
        
        let preferences = UserDefaults.standard
        var newDistance:CLLocationDistance = preferences.object(forKey: Constants.Preferences.MapLocationDistance) as? CLLocationDistance ?? minValue
        
        // We will clip the lowest value up to a default, this can happen via a previous version of the app
        if newDistance < minValue
        {
            newDistance = minValue
        }
        
        return newDistance
        
    }
    
    /**
     Check the user preferences for deferred distance
     
     - returns: <#return value description#>
     */
    class func GetUserPreferencesDeferredDistance() -> CLLocationDistance {
        
        let minValue:CLLocationDistance = 150;

        let preferences = UserDefaults.standard
        var newDistance:CLLocationDistance = preferences.object(forKey: Constants.Preferences.MapLocationDeferredDistance) as? CLLocationDistance ?? minValue
        
        // We will clip the lowest value up to a default, this can happen via a previous version of the app
        if newDistance < minValue
        {
            newDistance = minValue
        }

        return newDistance
        
    }
    
    /**
     Check the user preferences for accuracy setting
     
     - returns: <#return value description#>
     */
    class func GetUserPreferencesDeferredTimeout() -> TimeInterval {
        
        let minValue:TimeInterval = 180
        
        let preferences = UserDefaults.standard
        var newTime:TimeInterval = preferences.object(forKey: Constants.Preferences.MapLocationDeferredTimeout) as? TimeInterval ?? minValue
        
        // We will clip the lowest value up to a default, this can happen via a previous version of the app
        if newTime < minValue
        {
            newTime = minValue
        }
        
        return newTime
    }
 
}
