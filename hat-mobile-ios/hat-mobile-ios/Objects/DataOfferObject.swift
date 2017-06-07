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

struct DataOfferObject {
    
    // MARK: - Variables
    
    var name: String = ""
    var details: String = ""
    var imageURL: String = ""
    var offerDescription: String = ""
    var offersRemaining: String = ""

    var requirements: [String] = []

    var image: UIImage? = nil
    
    var isPPIRequested: Bool = false
    
    // MARK: - Initialisers
    
    init() {
        
        name = "Starbucks"
        details = "expires 01/06/2017"
        image = UIImage(named: "Image Placeholder")
        offerDescription = "blah blah"
        requirements = ["none"]
        offersRemaining = "150"
        isPPIRequested = true
    }

}
