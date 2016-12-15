//
//  DataPlugsService.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 13/12/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import Alamofire

class DataPlugsService: NSObject {
    
    class func getApplicationTokenFor(serviceName: String, resource: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) -> Void {
            
            let parameters = ["name" : serviceName,
                              "resource" : resource]
            var headers = ["" : ""]
            
            if let token = Helper.GetKeychainValue(key: "UserToken") {
                
                headers = ["X-Auth-Token": token]
            }
            
            let userDomain = HatAccountService.TheUserHATDomain()
            let url = "https://" + userDomain + "/users/application_token?"
            
            NetworkHelper.AsynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers, completion: { (r: Helper.ResultType) -> Void in
                
                switch r {
                    
                case .error( _, _):
                    
                    failCallBack()
                case .isSuccess(let isSuccess, _, let result):
                    
                    if isSuccess {
                        
                        succesfulCallBack(result[0]["value"].stringValue)
                    }
                }
            })
        
    }
    
    class func ensureDataPlugReady(succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) -> Void {
        
        let offerID = "hardcodedofferid"
        
        let plugReadyContinue = ensureOfferEnabled(offerID: offerID, succesfulCallBack: succesfulCallBack, failCallBack: failCallBack)
        let checkPlugForToken = checkSocialPlugAvailability(succesfulCallBack: plugReadyContinue, failCallBack: failCallBack)
        
        getApplicationTokenFor(serviceName: "MarketSquare", resource: "https://marketsquare.hubofallthings.net", succesfulCallBack: checkPlugForToken, failCallBack: failCallBack)
    }
    
    class func ensureOfferEnabled(offerID: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) -> (String) -> Void {
        
        return {_ in
            
            let offerClaimForToken = ensureOfferDataDebitEnabled(offerID: offerID, succesfulCallBack: succesfulCallBack, failCallBack: failCallBack)
            getApplicationTokenFor(serviceName: "MarketSquare", resource: "https://marketsquare.hubofallthings.net", succesfulCallBack: offerClaimForToken, failCallBack: failCallBack)
        }
    }
    
    class func ensureOfferDataDebitEnabled(offerID: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) ->  (_ appToken: String) -> Void {
        
        return { (appToken: String) in
            
            let claimDDForOffer = approveDataDebitPartial(appToken: appToken, succesfulCallBack: succesfulCallBack, failCallBack: failCallBack)
            
            ensureOfferClaimed(offerID: offerID, succesfulCallBack: claimDDForOffer, failCallBack: failCallBack)(appToken)
        }
    }
    
    class func ensureOfferClaimed(offerID: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) ->  (_ appToken: String) -> Void {
        
        return { (appToken: String) in
            
            let claimOfferIfFailed = claimOfferWithOfferIDPartial(offerID: offerID, appToken: appToken,
                                                                  succesfulCallBack: succesfulCallBack,
                                                                  failCallBack: failCallBack)
            checkIfOfferIsClaimed(offerID: offerID, appToken: appToken,
                                  succesfulCallBack: succesfulCallBack,
                                  failCallBack: claimOfferIfFailed)
        }
    }
    
    class func checkIfOfferIsClaimedPartial(offerID: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) ->  (_ appToken: String) -> Void {
        
        return { (appToken: String) in
            
            checkIfOfferIsClaimed(offerID: offerID, appToken: appToken, succesfulCallBack: succesfulCallBack, failCallBack: failCallBack)
        }
    }
    
    class func claimOfferWithOfferIDPartial(offerID: String, appToken: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) -> (Void) -> Void {
        
        return {
            
            claimOfferWithOfferID(offerID, appToken: appToken,
                                  succesfulCallBack: succesfulCallBack,
                                  failCallBack: failCallBack)
        }
    }
    

    class func checkIfOfferIsClaimed(offerID: String, appToken: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) ->  Void {
    
        let parameters = ["" : ""]
        let headers = ["X-Auth-Token": appToken]
        
        let url = "https://marketsquare.hubofallthings.com/offer/" + offerID + "/userClaim"
        
        NetworkHelper.AsynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers, completion: { (r: Helper.ResultType) -> Void in
            
            switch r {
                
            case .error( _, _):
                
                failCallBack()
            case .isSuccess(let isSuccess, _, let result):
                
                if isSuccess {
                    // TODO: call the callback with Data Debit ID from the result
                    
                    succesfulCallBack(result[0]["value"].stringValue)
                }
            }
        })
    }
    
    class func claimOfferWithOfferID(_ offerID: String, appToken: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) ->  Void {
        
        let parameters = ["" : ""]
        let headers = ["X-Auth-Token": appToken]
        
        let url = "https://marketsquare.hubofallthings.com/offer/" + offerID + "/claim"
        
        NetworkHelper.AsynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers, completion: { (r: Helper.ResultType) -> Void in
            
            switch r {
                
            case .error( _, _):
                
                failCallBack()
            case .isSuccess(let isSuccess, _, let result):
                
                if isSuccess {
                    
                    succesfulCallBack(result[0]["value"].stringValue)
                }
            }
        })
    }
    
    class func approveDataDebitPartial(appToken: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) -> (_ dataDebitID: String) -> Void {
        
        return { (dataDebitID: String) in
            
            approveDataDebit(dataDebitID, appToken: appToken, succesfulCallBack: succesfulCallBack, failCallBack: failCallBack)
        }
    }
    
    class func approveDataDebit(_ dataDebitID: String, appToken: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) ->  Void {
        
        let parameters = ["" : ""]
        let headers = ["X-Auth-Token": appToken]
        let userDomain = HatAccountService.TheUserHATDomain()
        
        let url = "https://" + userDomain + "/dataDebit/" + dataDebitID + "/enable"
        
        NetworkHelper.AsynchronousRequest(url, method: .put, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers, completion: { (r: Helper.ResultType) -> Void in
            
            switch r {
                
            case .error( _, _):
                
                failCallBack()
            case .isSuccess(let isSuccess, _, let result):
                
                if isSuccess {
                    // TODO
                    succesfulCallBack(result[0]["value"].stringValue)
                }
            }
        })
    }
    
    class func checkSocialPlugAvailability(succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (Void) -> Void) -> (_ appToken: String) ->  Void {
        
        return { (appToken: String) in
            
            let parameters = ["" : ""]
            let headers = ["X-Auth-Token": appToken]
            
            let url = "https://social-plug.hubofallthings.com/api/user/token/status"
            
            NetworkHelper.AsynchronousRequest(url, method: .put, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers, completion: { (r: Helper.ResultType) -> Void in
                
                switch r {
                    
                case .error( _, _):
                    
                    failCallBack()
                case .isSuccess(let isSuccess, _, let result):
                    
                    if isSuccess {
                        
                        succesfulCallBack(result[0]["value"].stringValue)
                    }
                }
            })
        }
    }
}
