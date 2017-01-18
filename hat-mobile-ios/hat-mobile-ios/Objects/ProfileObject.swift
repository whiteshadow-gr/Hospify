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

/// A struct representing the profile object for the profile view controller
struct ProfileObject {
    
    // MARK: - Variables
    
    /// The profile title for this tile
    var profileTileLabel: String = ""
    
    /// The image for this tile
    var profileTileImage: UIImage = UIImage()
    
    // MARK: - Initializers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        profileTileLabel = ""
        
        profileTileImage = UIImage()
    }
    
    /**
     It initialises everything according the desired title and image
     */
    init(with title: String, and image: UIImage) {
        
        profileTileLabel = title
        
        profileTileImage = image
    }
}
