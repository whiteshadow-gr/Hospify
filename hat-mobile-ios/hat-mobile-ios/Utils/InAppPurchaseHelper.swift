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

import StoreKit

// MARK: Class

class InAppPurchaseHelper: NSObject, SKProductsRequestDelegate {
    
    // MARK: - Variables

    var productIDs: Set = ["hat_hatdex_subscription_trial"]
    
    var productsArray: Array<SKProduct> = []
    
    /// The delegate variable of the protocol for gps tracking
    weak var inAppPurchaseDelegate: InAppPurchasesDelegateProtocol?
    
    // MARK: - StoreKit Functions
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        if response.products.count != 0 {
            
            for product in response.products {
                
                productsArray.append(product)
            }
            
            print(productsArray)
        } else {
            
            print("There are no products.")
        }
        
        if response.invalidProductIdentifiers.count != 0 {
            
            print(response.invalidProductIdentifiers.description)
        }
        
        inAppPurchaseDelegate?.inAppPurchaseRequest(request, didReceive: response, products: productsArray)
    }
    
    // MARK: - Request products
    
    func requestProductInfo() {
        
        if SKPaymentQueue.canMakePayments() {
            
            let productRequest = SKProductsRequest(productIdentifiers: productIDs)
            
            productRequest.delegate = self
            productRequest.start()
        } else {
            
            print("Cannot perform In App Purchases.")
        }
    }

}
