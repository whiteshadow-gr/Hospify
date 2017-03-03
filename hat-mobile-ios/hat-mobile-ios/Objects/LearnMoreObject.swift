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

import UIKit

// MARK: Struct

/// LearnMoreObject used in learn more button in the login screen
class LearnMoreObject {
    
    // MARK: - Variables

    /// The title of the page
    var title: String
    /// The main body of the page
    var info: String
    /// The button title if any
    var buttonTitle: String
    
    /// The image
    var image: UIImage
    
    // MARK: - Initialisers
    
    /**
     Inits with default values
     */
    init() {
        
        title = ""
        info = ""
        buttonTitle = ""
        image = UIImage(named: "Profile")!
    }
    
    /**
     Inits with a page number to load predefined values
     
     - parameter pageNumber: The number of the page to create
     */
    convenience init(pageNumber: Int) {
        
        self.init()
        
        if pageNumber == 0 {
            
            title = "The HAT is your own data store"
            info = "Υour words, information, photos, music; everything on the Internet that is personal to you, is your data\n\nClaim your data, safely use and share it on demand, everywhere you go \n\nHave control and privacy"
            image = UIImage(named: "Data store")!
        } else if pageNumber == 1 {
            
            title = "The HAT belongs to you, the individual"
            info = "You choose your HAT provider \n\nYour provider has no right to access your data unless you give them permission"
            image = UIImage(named: "Individual")!
        } else if pageNumber == 2 {
            
            title = "The HAT is secure"
            info = "A state-of-the-art container technology for a data store on demand \n\nSynchronise with organisations instead of having so many sets of your data out there"
            image = UIImage(named: "Secure")!
        } else if pageNumber == 3 {
            
            title = "The HAT is portable"
            info = "You can move your HAT to a provider you like\n\n(or even bring it to your own server at home)"
            image = UIImage(named: "Portable")!
        } else if pageNumber == 4 {
            
            title = "The HAT changes the future of the Internet"
            info = "Your data and words can become your history and memory for health, well being and personalised products \n\nYour HAT can be a personal data assistant with a wiki-me!"
            image = UIImage(named: "Future")!
        } else if pageNumber == 5 {
            
            title = "The HAT is built on research"
            info = "£1.7m, 6 UK universities, 7 professors and 20 researchers worked on the design of the technology, business and economic models"
            image = UIImage(named: "Research")!
        } else if pageNumber == 6 {
            
            title = "The HAT stands for the Hub-of-All-Things"
            info = "Because we think you should be at the hub of all things"
            image = UIImage(named: "Stands for")!
            buttonTitle = "What you can do with your HAT"

        } else if pageNumber == 10 {
            
            title = "Stuff your HAT!"
            info = "Claim data from Internet companies and make it useful to YOU \n\nWith just a few key presses (We think it's like printing money)."
            image = UIImage(named: "Stuff your HAT")!
        } else if pageNumber == 11 {
            
            title = "Use HAT Services"
            info = "Post updates on social media, fill information on forms, sign on to web services, share data for personalised quotations and offers"
            image = UIImage(named: "HAT Service")!
        } else if pageNumber == 12 {
            
            title = "Monetise"
            info = "Use your data to have discounts and vouchers \n\nReuse your data again and again"
            image = UIImage(named: "Monetize")!
        } else if pageNumber == 13 {
            
            title = "Personalise"
            info = "With your PHATA (personal HAT address) a 'PO Box' for your HAT e.g. https://yourHATname.hubofallthings.net"
            image = UIImage(named: "Personalize")!
        } else if pageNumber == 14 {
            
            title = "Get smart"
            info = "Gain insights from your data to help you with buying, nutrition and many life decisions!"
            image = UIImage(named: "Get Smart")!
            
        } else if pageNumber == 20 {
            
            title = "Welcome to Rumpel Lite!"
            info = "\nThe dashboard for all your HAT data"
            image = UIImage(named: "Rumpel")!
        } else if pageNumber == 21 {
            
            title = "Your HAT is your personal data container"
            info = "Claim, control and utilise the data you generate. Only you can access your HAT data, with complete control over who you share it with"
            image = UIImage(named: "TealBinary")!
        } else if pageNumber == 22 {
            
            title = "Control your data"
            info = "Collect your data, such as your locations and social media posts, and create new data with Rumpel's Notables tool – completely privately"
            image = UIImage(named: "TealFingerprint")!
        } else if pageNumber == 23 {
            
            title = "Head to your profile to set up your PHATA(Personal HAT Address) page"
            info = ""
            image = UIImage(named: "TealDevices")!
        }
    }
}
