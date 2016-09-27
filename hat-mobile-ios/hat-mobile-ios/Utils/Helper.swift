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
        case IsSuccess(isSuccess: Bool, statusCode: Int!, result: JSON)
        case Error(error: ErrorType, statusCode: Int!)
    }
    
    /**
     Used for tyime interval creation
     
     - Future: <#Future description#>
     - Past:   <#Past description#>
     */
    enum TimeType {
        case Future
        case Past
    }
    
    enum TimePeriodSelected {
        case None
        case Yesyerday
        case Today
        case LastWeek
    }
    /**
     Trim a given String
     
     - parameter string: the String to trim
     
     - returns: trimmed String
     */
    class func TrimString(string: String) -> String
    {
        return string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
    }
    
    struct FutureTimeInterval {
        var interval: NSTimeInterval
        
        init(days: NSTimeInterval, timeType: TimeType) {
            var timeBase:Double = 24
            switch timeType {
            case .Future:
                timeBase = abs(timeBase)
                break;
            case .Past:
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
    class func TimeAgoSinceDate(date: NSDate) -> String{
        
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let earliest = now.earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:NSDateComponents = calendar.components([NSCalendarUnit.Minute , NSCalendarUnit.Hour , NSCalendarUnit.Day , NSCalendarUnit.WeekOfYear , NSCalendarUnit.Month , NSCalendarUnit.Year , NSCalendarUnit.Second], fromDate: earliest, toDate: latest, options: NSCalendarOptions())
    
        if (components.year >= 2) {
            return NSLocalizedString("Last year", comment: "")
        } else if (components.month >= 2) {
            return String.localizedStringWithFormat(NSLocalizedString("%d months ago", comment: ""), components.month)
        } else if (components.weekOfYear >= 1){
            return NSLocalizedString("A week ago", comment: "")
        } else if (components.day >= 2) {
            return String.localizedStringWithFormat(NSLocalizedString("%d days ago", comment: ""), components.day)
        } else if (components.day >= 1){
            return NSLocalizedString("A day ago", comment: "")
        } else if (components.hour >= 2) {
            return String.localizedStringWithFormat(NSLocalizedString("%d hours ago", comment: ""), components.hour)
        } else if (components.hour >= 1){
            return NSLocalizedString("An hour ago", comment: "")
        } else if (components.minute >= 2) {
            return String.localizedStringWithFormat(NSLocalizedString("%d minutes ago", comment: ""), components.minute)
        } else if (components.minute >= 1){
            return NSLocalizedString("A minute ago", comment: "")
        } else if (components.second >= 3) {
            return String.localizedStringWithFormat(NSLocalizedString("%d seconds ago", comment: ""), components.second)
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
        let preferences = NSUserDefaults.standardUserDefaults()
        let userHATDomain:Constants.UserHATDomainAlias = preferences.objectForKey(Constants.Preferences.UserHATDomain) as? Constants.UserHATDomainAlias ?? ""
        
        return userHATDomain
    }
    
    /**
     Construct the headres for the Requests
     
     - parameter xAuthToken: <#xAuthToken description#>
     
     - returns: [String: String]
     */
    class func ConstructRequestHeaders(xAuthToken: String) -> [String: String] {
        
        let headers = ["Accept": "application/json", "Content-Type": "application/json", "X-Auth-Token": xAuthToken]

        return headers
    }
    
    /**
     Register with HAT url
     
     - returns: HATRegistrationURLAlias
     */
    class func TheAppRegistrationWithHATURL(userHATDomain: String) -> Constants.HATRegistrationURLAlias
    {
        // sample format
        // GET
        // https://marketsquare.hubofallthings.net/api/dataplugs/${MARKET_DATA_PLUG_ID}/connect?hat=${HAT_DOMAIN}

        if let escapedUserHATDomain:String = userHATDomain.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
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
                "http://" +
                    self.TheUserHATDomain() + /* hat domain for the user */
                    "/users/access_token?username=" +
                    self.TheHATUsername() +
                    "&password=" +
                    self.TheHATPassword()
        
        return url
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
            "http://" +
                self.TheUserHATDomain() + /* hat domain for the user */
                "/data/table?name=" +
                Constants.HATDataSource().name +
                "&source=" +
                Constants.HATDataSource().source
        
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
                "http://" +
                    self.TheUserHATDomain() + /* hat domain for the user */
                    "/data/table"
        
        return url
    }
   
    
    /**
     If the datasource exists, we can get the field info using:
        http://${DOMAIN}/data/table/${TABLE_ID}`
     - returns: String
     */
    class func TheGetFieldInformationUsingTableIDURL(fieldID: Int) -> String
    {
        // sample format
        // POST
        // http://${HAT_DOMAIN}/data/record/values
        // Headers: ‘X-Auth-Token’: ${HAT_ACCESS_TOKEN}
        
        let url:String =
            "http://" +
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
            "http://" +
                self.TheUserHATDomain() + /* hat domain for the user */
                "/data/record/values"
        
        return url
    }

    class func getDateFromString(dateString : String) -> NSDate!
    {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = Constants.DateFormats.UTC 
        formatter.timeZone = NSTimeZone(abbreviation: "UTC")
        let date = formatter.dateFromString(dateString)
        
        return date
    }
    
    class func getDateString(datetime : NSDate) -> String
    {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.FullStyle
        formatter.timeStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeZone = NSTimeZone(abbreviation: "UTC")

        let date = formatter.stringFromDate(datetime)
        
        return date
    }
    
    class func getDateString(datetime : NSDate, format: String) -> String
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = NSTimeZone(abbreviation: "UTC")

        let date = formatter.stringFromDate(datetime)
        
        return date
    }
    
    class func UIColorFromRGB(rgbValue: UInt) -> UIColor {
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
    class func ExceptionFriendlyMessage(errorCode: Int!, defaultMessage: String) -> String {
        
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
 
    
}
