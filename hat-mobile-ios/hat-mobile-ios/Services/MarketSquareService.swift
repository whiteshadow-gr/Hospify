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

// MARK: Struct

struct MarketSquareService {
    
    // MARK: - Methods
    
    /**
     Get the Market Access Token for the iOS data plug
     
     - returns: MarketAccessToken
     */
    static func TheMarketAccessToken() -> Constants.MarketAccessTokenAlias {
        
        return Constants.HATDataPlugCredentials.Market_AccessToken
    }
    
    /**
     Get the Market Access Token for the iOS data plug
     
     - returns: MarketDataPlugID
     */
    static func TheMarketDataPlugID() -> Constants.MarketDataPlugIDAlias {
        
        return Constants.HATDataPlugCredentials.Market_DataPlugID
    }
    
    /**
     Register with HAT url
     
     - parameter userHATDomain: The user's hat domain
     - returns: HATRegistrationURLAlias
     */
    static func TheAppRegistrationWithHATURL(_ userHATDomain: String) -> Constants.HATRegistrationURLAlias {
        
        if let escapedUserHATDomain: String = userHATDomain.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            
            let url: Constants.HATRegistrationURLAlias = Constants.RequestUrls.AppRegistrationWithHATURL +
                self.TheMarketDataPlugID() + "/" + "connect?hat=" + escapedUserHATDomain
            
            return url
        }
        
        return ""
    }
    
    // MARK: - Get app token
    
    /**
     Gets application token for facebook
     
     - parameter successful: An @escaping (String) -> Void method executed on a successful response
     - parameter failed: An @escaping (Void) -> Void) method executed on a failed response
     */
    static func getAppTokenForMarketsquare(successful: @escaping (String) -> Void, failed: @escaping (Void) -> Void) {
        
        DataPlugsService.getApplicationTokenFor(serviceName: "MarketSquare", resource: "https://marketsquare.hubofallthings.com", succesfulCallBack: successful, failCallBack: failed)
    }
    
}
