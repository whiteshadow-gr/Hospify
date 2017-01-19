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
    
}
