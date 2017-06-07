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

import Foundation

/**
 The strings needed for communicating with twitter data plug
 
 - statusURL: No token detected
 - dataPlugURL: No issuer of the token detected. Includes a description(String)
 - tableName: General error. Includes a description(String), the statusCode(Int?) and the error(Error?)
 - sourceName: Cannot decode token. Includes a description(String)
 - serviceName: Cannot split token. Includes a description(String)
 */
public enum Twitter {
    
    static let statusURL = "https://twitter-plug.hubofallthings.com/api/status"
    static let dataPlugURL = "https://twitter-plug.hubofallthings.com"
    static let tableName = "tweets"
    static let sourceName = "twitter"
    static let serviceName = "Twitter"
}

/**
 The strings needed for communicating with facebook data plug
 
 - statusURL: No token detected
 - dataPlugURL: No issuer of the token detected. Includes a description(String)
 - tableName: General error. Includes a description(String), the statusCode(Int?) and the error(Error?)
 - sourceName: Cannot decode token. Includes a description(String)
 - serviceName: Cannot split token. Includes a description(String)
 */
public enum Facebook {
    
    static let statusURL = "https://social-plug.hubofallthings.com/api/user/token/status"
    static let dataPlugURL = "https://social-plug.hubofallthings.com"
    static let tableName = "posts"
    static let sourceName = "facebook"
    static let serviceName = "Facebook"
}

/**
 The strings needed for communicating with notables service
 
 - tableName: No token detected
 - sourceName: No issuer of the token detected. Includes a description(String)
 */
public enum Notables {
    
    static let tableName = "notablesv1"
    static let sourceName = "rumpel"
}

/**
The request headers
 
 - xAuthToken: No token detected
 */
public enum RequestHeaders {
    
    static let xAuthToken = "X-Auth-Token"
}

/**
 The content type
 
 - JSON: No token detected
 - Text: No issuer of the token detected. Includes a description(String)
 */
public enum ContentType {
    
    static let JSON = "application/json"
    static let Text = "text/plain"
}

/**
 The authentication used for sending locations to HAT
 
 - URLScheme: No token detected
 - ServiceName: No issuer of the token detected. Includes a description(String)
 - LocalAuthHost: General error. Includes a description(String), the statusCode(Int?) and the error(Error?)
 - NotificationHandlerName: Cannot decode token. Includes a description(String)
 - TokenParamName: Cannot split token. Includes a description(String)
 */
public enum Auth {
    
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
 The authentication data used by location service
 
 - HAT_Username: No token detected
 - HAT_Password: No issuer of the token detected. Includes a description(String)
 - Market_DataPlugID: General error. Includes a description(String), the statusCode(Int?) and the error(Error?)
 - Market_AccessToken: Cannot decode token. Includes a description(String)
 */
public enum HATDataPlugCredentials {
    
    /// hat username used for location data plug
    static let HAT_Username = "location"
    /// hat password used for location data plug
    static let HAT_Password = "MYl06ati0n"
    /// market data plug id used for location data plug
    static let Market_DataPlugID = "c532e122-db4a-44b8-9eaf-18989f214262"
    /// market access token used for location data plug
    static let Market_AccessToken: String = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxLVZyaHVrWFh1bm9LRVwvd3p2Vmh4bm5FakdxVHc2RCs3WVZoMnBLYTdIRjJXbHdUV29MQWR3K0tEdzZrTCtkQjI2eHdEbE5sdERqTmRtRlwvVWtWM1A2ODF3TXBPSUxZbFVPaHI1WnErTT0iLCJkYXRhcGx1ZyI6ImM1MzJlMTIyLWRiNGEtNDRiOC05ZWFmLTE4OTg5ZjIxNDI2MiIsImlzcyI6ImhhdC1tYXJrZXQiLCJleHAiOjE1MTU2MDQ3NzUsImlhdCI6MTQ4NDg0NjM3NSwianRpIjoiZTBlMjIwY2VmNTMwMjllZmQ3ZDFkZWQxOTQzYzdlZWE5NWVjNWEwNGI4ZjA1MjU1MzEwNDgzYTk1N2VmYTQzZWZiMzQ5MGRhZThmMTY0M2ViOGNhNGVlOGZkNzI3ZDBiZDBhZGQyZTgzZWZkNmY4NjM2NWJiMjllYjY2NzQ3MWVhMjgwMmQ4ZTdkZWIxMzlhZDUzY2UwYzQ1ZTgxZmVmMGVjZTI5NWRkNTU0N2I2ODQzZmRiZTZlNjJmZTU1YzczYzAyYjA4MDAzM2FlMzQyMWUxZWJlMGFhOTgzNmE4MGNjZjQ0YmIxY2E1NmQ0ZjM4NWJkMzg1ZDY4ZmY0ZTIwMyJ9.bPTryrVhFa2uAMSZ6A5-Vvca7muEf8RrWoiire7K7ko"
}
