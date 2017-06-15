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

// MARK: Struct

struct DataOfferObject {
    
    // MARK: - Variables
    
    var id: String = ""
    var title: String = ""
    var shortDescription: String = ""
    var longDescription: String = ""
    var illustrationURL: String = ""
    
    var created: Int = -1
    var offerStarts: Int = -1
    var offerExpires: Int = -1
    var collectsDataFor: Int = -1
    var requiredMinUsers: Int = -1
    var requiredMaxUsers: Int = -1
    var usersClaimedOffer: Int = -1
    
    var requiredDataDefinition: [DataOfferRequiredDataDefinitionObject] = []
    
    var reward: DataOfferRewarsObject = DataOfferRewarsObject()
    
    var issuer: DataOfferIssuerObject = DataOfferIssuerObject()
    
    var image: UIImage? = nil
    
    var isPPIRequested: Bool = false
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        id  = ""
        title = ""
        shortDescription = ""
        longDescription = ""
        illustrationURL = ""
        
        created = -1
        offerStarts = -1
        offerExpires = -1
        collectsDataFor = -1
        requiredMinUsers = -1
        requiredMaxUsers = -1
        usersClaimedOffer = -1
        
        requiredDataDefinition = []
        
        reward = DataOfferRewarsObject()
        
        issuer = DataOfferIssuerObject()
        
        image = nil

        isPPIRequested = false
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    init(dictionary: Dictionary<String, JSON>) {
        
        if let tempID = dictionary["id"]?.string {
            
            id = tempID
        }
        
        if let tempCreated = dictionary["created"]?.int {
            
            created = tempCreated
        }
        
        if let tempTitle = dictionary["title"]?.string {
            
            title = tempTitle
        }
        
        if let tempShortDescription = dictionary["shortDescription"]?.string {
            
            shortDescription = tempShortDescription
        }
        
        if let tempLongDescription = dictionary["longDescription"]?.string {
            
            longDescription = tempLongDescription
        }
        
        if let tempIllustrationUrl = dictionary["illustrationUrl"]?.string {
            
            illustrationURL = tempIllustrationUrl
        }
        
        if let tempOfferStarts = dictionary["starts"]?.int {
            
            offerStarts = tempOfferStarts
        }
        
        if let tempOfferExpires = dictionary["expires"]?.int {
            
            offerExpires = tempOfferExpires
        }
        
        if let tempCollectOfferFor = dictionary["collectFor"]?.int {
            
            collectsDataFor = tempCollectOfferFor
        }
        
        if let tempRequiresMinUsers = dictionary["requiredMinUser"]?.int {
            
            requiredMinUsers = tempRequiresMinUsers
        }
        
        if let tempRequiresMaxUsers = dictionary["requiredMaxUser"]?.int {
            
            requiredMaxUsers = tempRequiresMaxUsers
        }
        
        if let tempUserClaims = dictionary["userClaims"]?.int {
            
            usersClaimedOffer = tempUserClaims
        }
        
        if let tempRequiredDataDefinition = dictionary["requiredDataDefinition"]?.array {
            
            if tempRequiredDataDefinition.count > 0 {
                
                for dataDefination in tempRequiredDataDefinition {
                    
                    requiredDataDefinition.append(DataOfferRequiredDataDefinitionObject(dictionary: dataDefination.dictionaryValue))
                }
            }
        }
        
        if let tempReward = dictionary["reward"]?.dictionary {
            
            reward = DataOfferRewarsObject(dictionary: tempReward)
        }
        
        if let tempIssuer = dictionary["issuer"]?.dictionary {
            
            issuer = DataOfferIssuerObject(dictionary: tempIssuer)
        }
    }

}
