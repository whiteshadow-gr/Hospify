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

import HatForIOS
import JWTDecode

// MARK: Extension

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
    
    // MARK: - Check if token is active
    
    /**
     Checks if token has expired
     
     - parameter token: The token to check if expired
     - returns: The token if everything ok, 401 if token has expired or error if something went wrong
     */
    class func checkIfTokenExpired(token: String, expiredCallBack: (Void) -> Void, tokenValidCallBack: (String?) -> Void, errorCallBack: (String, String, String, @escaping (Void) -> Void) -> Void) {
        
        do {
            
            let jwt = try decode(jwt: token)
            print(token)
            if jwt.expired {
                
                expiredCallBack()
            } else {
                
                tokenValidCallBack(token)
            }
        } catch {
            
            errorCallBack("Checking token expiry date failed, please log out and log in again", "Error", "OK", {})
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
    
    // MARK: - Constructing URLs
    
    /**
     Should be performed before each data post request as token lifetime is short.
     
     - returns: UserHATAccessTokenURLAlias
     */
    class func TheUserHATAccessTokenURL() -> Constants.UserHATAccessTokenURLAlias {
        
        let url: Constants.UserHATAccessTokenURLAlias = "https://" + self.TheUserHATDomain() +
            "/users/access_token?username=" + self.TheHATUsername() + "&password=" + self.TheHATPassword()
        
        return url
    }
    
    /**
     Constructs the url to access the table we want
     
     - parameter tableName: The table name
     - parameter sourceName: The source name
     - returns: String
     */
    class func TheUserHATCheckIfTableExistsURL(tableName: String, sourceName: String) -> String {
        
        return "https://" + self.TheUserHATDomain() + "/data/table?name=" + tableName + "&source=" + sourceName
    }
    
    /**
     Constructs the URL in order to create new table. Should be performed only if there isn’t an existing data source already.
     
     - returns: String
     */
    class func TheConfigureNewDataSourceURL() -> String {
        
        return "https://" + self.TheUserHATDomain() + "/data/table"
    }
    
    /**
     Constructs the URL to get a field from a table
     
     - parameter fieldID: The fieldID number
     - returns: String
     */
    class func TheGetFieldInformationUsingTableIDURL(_ fieldID: Int) -> String {
        
        return "https://" + self.TheUserHATDomain() + "/data/table/" + String(fieldID)
    }
    
    /**
     Constructs the URL to post data to HAT
     
     - returns: String
     */
    class func ThePOSTDataToHATURL() -> String {
        
        return "https://" + self.TheUserHATDomain() + "/data/record/values"
    }
    
    // MARK: - Upload file to hat
    
    /**
     Uploads a file to HAT
     
     - parameter token: The user's token
     - parameter userDomain: The user's domain
     - parameter fileToUpload: The image to upload
     - parameter progressUpdater: A function to execute on the progress of the upload is moving forward
     - parameter completion: A function to execute on success
     - parameter errorCallBack: A Function to execute on failure
     */
    class func uploadFileToHATWrapper(token: String, userDomain: String, fileToUpload: UIImage, tags: [String], progressUpdater: ((Double) -> Void)?, completion: ((FileUploadObject, String?) -> Void)?, errorCallBack: ((HATTableError) -> Void)?) {
        
        HATAccountService.uploadFileToHAT(
            fileName: "rumpelPhoto",
            token: token,
            userDomain: userDomain, tags: tags,
            completion: {(fileObject, renewedUserToken) -> Void in
                
                let data = UIImageJPEGRepresentation(fileToUpload, 1.0)
                HATNetworkHelper.uploadFile(
                    image: data!,
                    url: fileObject.contentURL,
                    progressUpdateHandler: {(progress) -> Void in
                        
                        progressUpdater?(progress)
                },completion: {(result) -> Void in
                    
                    HATAccountService.completeUploadFileToHAT(fileID: fileObject.fileID, token: token, userDomain: userDomain, completion: {(uploadedFile, renewedUserToken) -> Void in
                    
                        // refresh user token
                        if renewedUserToken != nil {
                            
                            completion?(uploadedFile, renewedUserToken!)
                        } else {
                            
                            completion?(uploadedFile, nil)
                        }
                    }, errorCallback: {(error) -> Void in
                    
                        _ = CrashLoggerHelper.hatTableErrorLog(error: error)
                        errorCallBack?(error)
                    })
                })
            }, errorCallback: {(error) -> Void in
                
                _ = CrashLoggerHelper.hatTableErrorLog(error: error)
                errorCallBack?(error)
        })
    }
}
