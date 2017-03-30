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

import KeychainSwift
import Alamofire
import SwiftyJSON
import Crashlytics
import HatForIOS

// MARK: Class
extension HATAccountService {
    
    // MARK: - User's settings
    
    /**
     Get the Market Access Token for the iOS data plug
     
     - returns: HATUsername
     */
    class func TheHATUsername() -> Constants.HATUsernameAlias {
        
        return Constants.HATDataPlugCredentials.HAT_Username
    }
    
    /**
     Get the Market Access Token for the iOS data plug
     
     - returns: HATPassword
     */
    class func TheHATPassword() -> Constants.HATPasswordAlias {
        
        return Constants.HATDataPlugCredentials.HAT_Password
    }
    
    /**
     Get the Market Access Token for the iOS data plug
     
     - returns: UserHATDomainAlias
     */
    class func TheUserHATDomain() -> Constants.UserHATDomainAlias {
        
        if let hatDomain = KeychainHelper.GetKeychainValue(key: Constants.Keychain.HATDomainKey) {
            
            return hatDomain
        }
        
        return ""
    }
    
    /**
     Gets user's token from keychain
     
     - returns: The token as a string
     */
    class func getUsersTokenFromKeychain() -> String {
        
        // check if the token has been saved in the keychain and return it. Else return an empty string
        if let token = KeychainHelper.GetKeychainValue(key: "UserToken") {
            
            return token
        }
        
        return ""
    }
    
    class func checkIfTokenIsActive(token: String, success: @escaping (String) -> Void, failed: @escaping (Int) -> Void) {
        
        let userDomain = HATAccountService.TheUserHATDomain()
        
        HATAccountService.checkHatTableExists(userDomain: userDomain, tableName: "notablesv1", sourceName: "rumpel", authToken: token, successCallback: {(_: NSNumber) -> Void in
            
            success(token)
        }, errorCallback: {(error) -> Void in
            
            switch error {
                
            case .generalError(_, let statusCode, _) :
                
                if statusCode != nil {
                    
                    failed(statusCode!)
                }
            default:
                break
            }
        })
    }
    
    /**
     Logs any error found from triggering th update
     
     - parameter response: The DataResponse object returned from alamofire
     */
    private class func errorHandlingWith(response: DataResponse<String>) {
        
        // handle error codes
        print("Success: \(response.result.isSuccess)")
        print("Response String: \(String(describing: response.result.value))")
        
        // check for numerous errors
        var statusCode = response.response?.statusCode
        if statusCode != nil {
            
            print(statusCode!)
        }
        if let error = response.result.error as? AFError {
            
            statusCode = error._code // statusCode private
            switch error {
                
            case .invalidURL(let url):
                
                print("Invalid URL: \(url) - \(error.localizedDescription)")
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["Invalid URL" : "\(url) - \(error.localizedDescription)"])
            case .parameterEncodingFailed(let reason):
                
                print("Parameter encoding failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["Parameter encoding failed:" : "\(error.localizedDescription)", "Failure Reason:" : "\(reason)"])
            case .multipartEncodingFailed(let reason):
                
                print("Multipart encoding failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["Multipart encoding failed:" : "\(error.localizedDescription)", "Failure Reason:" : "\(reason)"])
            case .responseValidationFailed(let reason):
                
                print("Response validation failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["Response validation failed:" : "\(error.localizedDescription)", "Failure Reason:" : "\(reason)"])
                switch reason {
                    
                case .dataFileNil, .dataFileReadFailed:
                    
                    print("Downloaded file could not be read")
                    Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["Failure Reason:" : "Downloaded file could not be read"])
                case .missingContentType(let acceptableContentTypes):
                    
                    print("Content Type Missing: \(acceptableContentTypes)")
                    Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["Content Type Missing:" : "\(acceptableContentTypes)"])
                case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                    
                    print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                    Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["Response content type:" : "\(responseContentType) was unacceptable: \(acceptableContentTypes)"])
                case .unacceptableStatusCode(let code):
                    
                    print("Response status code was unacceptable: \(code)")
                    statusCode = code
                    Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["Response status code was unacceptable:" : "\(code)"])
                }
            case .responseSerializationFailed(let reason):
                
                print("Response serialization failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["Response serialization failed:" : "\(error.localizedDescription)", "Failure Reason:" : "\(reason)"])
                // statusCode = 3840 ???? maybe..
            }
            
            print("Underlying error: \(String(describing: error.underlyingError))")
            Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["Underlying error:" : "\(String(describing: error.underlyingError))"])
        } else if let error = response.result.error as? URLError {
            
            print("URLError occurred: \(error)")
            Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["URLError occurred:" : "\(error)"])
        } else {
            
            print("Unknown error: \(String(describing: response.result.error))")
            if let error = response.result.error {
                
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["Unknown error:" : "\(error)"])
            }
        }
    }
    
    // MARK: - Verify domain
    
    /**
     Verify the domain if it's what we expect
     
     - parameter domain: The formated doamain
     - returns: Bool, true if the domain matches what we expect and false otherwise
     */
    class func verifyDomain(_ domain: String) -> Bool {
        
        if domain == "hubofallthings.net" || domain == "warwickhat.net" || domain == "hubat.net" {
            
            return true
        }
        
        return false
    }
    
    /**
     Log in button pressed. Begin authorization
     
     - parameter userHATDomain: The user's domain
     - parameter successfulVerification: The function to execute on successful verification
     - parameter failedVerification: The function to execute on failed verification
     */
    class func logOnToHAT(userHATDomain: String?, successfulVerification: @escaping (String) -> Void, failedVerification: @escaping () -> Void) {
        
        var userDomain = userHATDomain
        // trim values
        guard let hatDomain = userDomain?.TrimString() else {
            
            return
        }
        
        // username guard
        guard let _userDomain = userDomain, !hatDomain.isEmpty else {
            
            userDomain = ""
            return
        }
        
        // split text field text by .
        var array = hatDomain.components(separatedBy: ".")
        // remove the first string
        array.remove(at: 0)
        
        // form one string
        var domain = ""
        for section in array {
            
            domain += section + "."
        }
        
        // chack if we are out of bounds and drop last leter
        if domain.characters.count > 1 {
            
            domain = String(domain.characters.dropLast())
        }
        
        // verify if the domain is what we want
        if HATAccountService.verifyDomain(domain) {
            
            // authorise user
            successfulVerification(_userDomain)
        } else {
            
            //show alert
            failedVerification()
        }
    }
    
    // MARK: - Constructing URLs
    
    /**
     Should be performed before each data post request as token lifetime is short.
     
     - returns: UserHATAccessTokenURLAlias
     */
    class func TheUserHATAccessTokenURL() -> Constants.UserHATAccessTokenURLAlias {
        
        let url: Constants.UserHATAccessTokenURLAlias = "https://" + HATAccountService.TheUserHATDomain() +
            "/users/access_token?username=" + HATAccountService.TheHATUsername() + "&password=" + HATAccountService.TheHATPassword()
        
        return url
    }
    
    /**
     Constructs the url to access the table we want
     
     - parameter tableName: The table name
     - parameter sourceName: The source name
     
     - returns: String
     */
    class func TheUserHATCheckIfTableExistsURL(tableName: String, sourceName: String) -> String {
        
        return "https://" + HATAccountService.TheUserHATDomain() + "/data/table?name=" + tableName + "&source=" + sourceName
    }
    
    /**
     Constructs the URL in order to create new table. Should be performed only if there isn’t an existing data source already.
     
     - returns: String
     */
    class func TheConfigureNewDataSourceURL() -> String {
        
        return "https://" + HATAccountService.TheUserHATDomain() + "/data/table"
    }
    
    /**
     Constructs the URL to get a field from a table
     
     - parameter fieldID: The fieldID number
     
     - returns: String
     */
    class func TheGetFieldInformationUsingTableIDURL(_ fieldID: Int) -> String {
        
        return "https://" + HATAccountService.TheUserHATDomain() + "/data/table/" + String(fieldID)
    }
    
    /**
     Constructs the URL to post data to HAT
     
     - returns: String
     */
    class func ThePOSTDataToHATURL() -> String {
        
        return "https://" + HATAccountService.TheUserHATDomain() + "/data/record/values"
    }
}
