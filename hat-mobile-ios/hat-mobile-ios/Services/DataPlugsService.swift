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

import Alamofire
import Crashlytics

// MARK: Class

/// The data plugs service class
class DataPlugsService: NSObject {
    
    // MARK: - Get available data plugs
    
    /**
     Gets the available data plugs for the user to enable
     
     - parameter succesfulCallBack: A function of type ([DataPlugObject]) -> Void, executed on a successful result
     - parameter failCallBack: A function of type (Void) -> Void, executed on an unsuccessful result
     */
    class func getAvailableDataPlugs(succesfulCallBack: @escaping ([DataPlugObject]) -> Void, failCallBack: @escaping (Void) -> Void) -> Void {
        
        let url: String = "https://marketsquare.hubofallthings.com/api/dataplugs"
        
        NetworkHelper.AsynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: [:], headers: [:], completion: { (r: NetworkHelper.ResultType) -> Void in
            
            switch r {
                
            // in case of error call the failCallBack
            case .error(let error, let statusCode):
                
                failCallBack()
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["error" : error.localizedDescription, "statusCode: " : String(describing: statusCode)])
            // in case of success call the succesfulCallBack
            case .isSuccess(let isSuccess, _, let result):
                
                if isSuccess {
                    
                    var returnValue: [DataPlugObject] = []
                    
                    for item in result.arrayValue {
                        
                        returnValue.append(DataPlugObject(dict: item.dictionaryValue))
                    }
                    
                    succesfulCallBack(returnValue)
                }
            }
        })
    }
    
    // MARK: - Application Token
    
    /**
     Gets the application level token from hat
     
     - parameter serviceName: The service name requesting the token
     - parameter resource: The resource for the token
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    class func getApplicationTokenFor(serviceName: String, resource: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) -> Void {
        
        // setup parameters and headers
        let parameters = ["name" : serviceName, "resource" : resource]
        var headers = ["" : ""]
    
        // get token
        if let token = KeychainHelper.GetKeychainValue(key: "UserToken") {
            
            headers = ["X-Auth-Token": token]
        }
    
        // contruct the url
        let userDomain = HatAccountService.TheUserHATDomain()
        let url = "https://" + userDomain + "/users/application_token?"
        
        // async request
        NetworkHelper.AsynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers, completion: { (r: NetworkHelper.ResultType) -> Void in
            
            switch r {
                
            // in case of error call the failCallBack
            case .error(let error, let statusCode):
                
                failCallBack()
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["error" : error.localizedDescription, "statusCode: " : String(describing: statusCode)])
            // in case of success call the succesfulCallBack
            case .isSuccess(let isSuccess, _, let result):
                
                if isSuccess {
                    
                    succesfulCallBack(result["accessToken"].stringValue)
                }
            }
        })
    }
    
    // MARK: - Wrappers
    
    /**
     Ensure if the data plug is ready
     
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    class func ensureDataPlugReady(succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) -> Void {
        
        // facebook offer ID
        let offerID = "32dde42f-5df9-4841-8257-5639db222e41"
        
        // set up the succesfulCallBack
        let plugReadyContinue = ensureOfferEnabled(offerID: offerID, succesfulCallBack: succesfulCallBack, failCallBack: failCallBack)
        let checkPlugForToken = checkSocialPlugAvailability(succesfulCallBack: plugReadyContinue, failCallBack: failCallBack)
        
        // get token async
        getApplicationTokenFor(serviceName: "Facebook", resource: "https://social-plug.hubofallthings.com", succesfulCallBack: checkPlugForToken, failCallBack: failCallBack)
    }
    
    /**
     Ensures offer is enabled
     
     - parameter offerID: The offerID as a String
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    class func ensureOfferEnabled(offerID: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) -> (String) -> Void {
        
        return {_ in
            
            // setup succesfulCallBack
            let offerClaimForToken = ensureOfferDataDebitEnabled(offerID: offerID, succesfulCallBack: succesfulCallBack, failCallBack: failCallBack)
            
            // get applicationToken async
            getApplicationTokenFor(serviceName: "MarketSquare", resource: "https://marketsquare.hubofallthings.com", succesfulCallBack: offerClaimForToken, failCallBack: failCallBack)
        }
    }
    
    /**
     Ensures offer data debit is enabled
     
     - parameter offerID: The offerID as a String
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    class func ensureOfferDataDebitEnabled(offerID: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) ->  (_ appToken: String) -> Void {
        
        return { (appToken: String) in
            
            // setup the succesfulCallBack
            let claimDDForOffer = approveDataDebitPartial(appToken: appToken, succesfulCallBack: succesfulCallBack, failCallBack: failCallBack)
            
            // ensure offer is claimed
            ensureOfferClaimed(offerID: offerID, succesfulCallBack: claimDDForOffer, failCallBack: failCallBack)(appToken)
        }
    }
    
    /**
     Ensure offer claimed
     
    - parameter offerID: The offerID as a String
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    class func ensureOfferClaimed(offerID: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) ->  (_ appToken: String) -> Void {
        
        return { (appToken: String) in
            
            // setup the succesfulCallBack
            let claimOfferIfFailed = claimOfferWithOfferIDPartial(offerID: offerID, appToken: appToken,
                                                                  succesfulCallBack: succesfulCallBack,
                                                                  failCallBack: failCallBack)
            // ensure offer is claimed
            checkIfOfferIsClaimed(offerID: offerID, appToken: appToken,
                                  succesfulCallBack: succesfulCallBack,
                                  failCallBack: claimOfferIfFailed)
        }
    }
    
    /**
     Claims offer for this offerID
     
     - parameter offerID: The offerID as a String
     - parameter appToken: The application token as a String
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    
    class func claimOfferWithOfferIDPartial(offerID: String, appToken: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) -> (Void) -> Void {
        
        return {
            
            // claim offer
            claimOfferWithOfferID(offerID, appToken: appToken,
                                  succesfulCallBack: succesfulCallBack,
                                  failCallBack: failCallBack)
        }
    }
    
    /**
     Approve data debit
     
     - parameter appToken: The application token as a String
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    class func approveDataDebitPartial(appToken: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) -> (_ dataDebitID: String) -> Void {
        
        return { (dataDebitID: String) in
            
            // get user token, we dont need apptoken for this
            let userToken = HatAccountService.getUsersTokenFromKeychain()
            
            // approve data debit
            approveDataDebit(dataDebitID, userToken: userToken, succesfulCallBack: succesfulCallBack, failCallBack: failCallBack)
        }
    }
    
    // MARK: - Claiming offers
    
    /**
     Check if offer is claimed
     
     - parameter offerID: The offerID as a String
     - parameter appToken: The application token as a String
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    class func checkIfOfferIsClaimed(offerID: String, appToken: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) ->  Void {
    
        // setup parameters and headers
        let parameters = ["" : ""]
        let headers = ["X-Auth-Token": appToken]
        
        // contruct the url
        let url = "https://marketsquare.hubofallthings.com/api/offer/" + offerID + "/userClaim"
        
        // make async request
        NetworkHelper.AsynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers, completion: { (r: NetworkHelper.ResultType) -> Void in
            
            switch r {
                
            // in case of error call the failCallBack
            case .error(let error, let statusCode):
                
                if statusCode != 404 {
                    
                    Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["error" : error.localizedDescription, "statusCode: " : String(describing: statusCode)])
                } else {
                    
                   failCallBack()
                }
            // in case of success call succesfulCallBack
            case .isSuccess(let isSuccess, let statusCode, let result):
                
                if isSuccess {
                    
                    if statusCode == 200 {
                        
                        if !result["confirmed"].boolValue {
                            
                            succesfulCallBack(result["dataDebitId"].stringValue)
                        } else {
                            
                            
                        }
                    }
                }
            }
        })
    }
    
    /**
     Claim offer with this ID
     
     - parameter offerID: The offerID as a String
     - parameter appToken: The application token as a String
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    class func claimOfferWithOfferID(_ offerID: String, appToken: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) ->  Void {
        
        // setup parameters and headers
        let parameters = ["" : ""]
        let headers = ["X-Auth-Token": appToken]
        
        // contruct the url
        let url = "https://marketsquare.hubofallthings.com/api/offer/" + offerID + "/claim"
        
        // make async request
        NetworkHelper.AsynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers, completion: { (r: NetworkHelper.ResultType) -> Void in
            
            switch r {
             
            // in case of error call the failCallBack
            case .error(let error, let statusCode):
                
                failCallBack()
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["error" : error.localizedDescription, "statusCode: " : String(describing: statusCode)])
            // in case of success call succesfulCallBack
            case .isSuccess(let isSuccess, let statusCode, let result):
                
                if isSuccess {
                    
                    if statusCode == 200 {
                        
                        succesfulCallBack(result["dataDebitId"].stringValue)
                    }
                }
            }
        })
    }
    
    // MARK: - Data debits
    
    /**
     Approve data debit
     
     - parameter dataDebitID: The data debit ID as a String
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    class func approveDataDebit(_ dataDebitID: String, userToken: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) ->  Void {
        
        // setup parameters and headers
        let parameters = ["" : ""]
        let headers = ["X-Auth-Token": userToken]
        
        // contruct the url
        let userDomain = HatAccountService.TheUserHATDomain()
        let url = "https://" + userDomain + "/dataDebit/" + dataDebitID + "/enable"
        
        // make async request
        NetworkHelper.AsynchronousRequest(url, method: .put, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers, completion: { (r: NetworkHelper.ResultType) -> Void in
            
            switch r {
                
            // in case of error call the failCallBack
            case .error(let error, let statusCode):
                
                failCallBack()
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["error" : error.localizedDescription, "statusCode: " : String(describing: statusCode)])
            // in case of success call succesfulCallBack
            case .isSuccess(let isSuccess, _, _):
                
                if isSuccess {
                    
                }
            }
        })
    }
    
    /**
     Check data debit with this ID
     
     - parameter dataDebitID: The data debit ID as a String
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    class func checkDataDebit(_ dataDebitID: String, userToken: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) ->  Void {
        
        // setup parameters and headers
        let parameters = ["" : ""]
        let headers = ["X-Auth-Token": userToken]
        
        // contruct the url
        let userDomain = HatAccountService.TheUserHATDomain()
        let url = "https://" + userDomain + "/dataDebit/" + dataDebitID
        
        // make async request
        NetworkHelper.AsynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers, completion: { (r: NetworkHelper.ResultType) -> Void in
            
            switch r {
                
            // in case of error call the failCallBack
            case .error( let error, let statusCode):
                
                if statusCode != 404 {
                    
                    Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["error" : error.localizedDescription, "statusCode: " : String(describing: statusCode)])
                } else {
                    
                    failCallBack()
                }
            // in case of success call succesfulCallBack
            case .isSuccess(let isSuccess, _, let result):
                
                if isSuccess {
                    
                    if result["enabled"].boolValue {
                        
                        
                    }
                }
            }
        })
    }
    
    // MARK: - Social plug
    
    /**
     Check social plug
     
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    class func checkSocialPlugAvailability(succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) -> (_ appToken: String) ->  Void {
        
        return { (appToken: String) in
            
            // setup parameters and headers
            let parameters = ["" : ""]
            let headers = ["X-Auth-Token": appToken]
            
            // contruct the url
            let url = "https://social-plug.hubofallthings.com/api/user/token/status"
            
            // make async request
            NetworkHelper.AsynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers, completion: { (r: NetworkHelper.ResultType) -> Void in
                
                switch r {
                    
                // in case of error call the failCallBack
                case .error(let error, let statusCode):
                    
                    if statusCode == 404 {
                        
                        // post notification to authorize facebook
                        NotificationCenter.default.post(name: NSNotification.Name("safari"), object: nil)
                    } else {
                        
                        failCallBack()
                        Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["error" : error.localizedDescription, "statusCode: " : String(describing: statusCode)])
                    }
                // in case of success call succesfulCallBack
                case .isSuccess(let isSuccess, _, let result):
                    
                    if isSuccess {
                        
                        succesfulCallBack(String(result["canPost"].boolValue))
                    }
                }
            })
        }
    }
}
