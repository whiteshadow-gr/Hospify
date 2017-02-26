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

// MARK: Class

/// A class representing the tiles in the home screen
class HomeScreenObject: NSObject {
    
    // MARK: - Variables

    /// The image for the tile
    var serviceImage: UIImage = UIImage()
    
    /// The service name of the tile
    var serviceName: String = ""
    /// The description of the tile
    var serviceDescription: String = ""
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    override init() {
        
        serviceName = ""
        serviceDescription = ""
        serviceImage = UIImage()
    }
    
    /**
     It initialises everything from the passed values
     */
    convenience init(name: String, description: String, image: UIImage) {
        
        self.init()
        
        serviceName = name
        serviceDescription = description
        serviceImage = image
    }
}
