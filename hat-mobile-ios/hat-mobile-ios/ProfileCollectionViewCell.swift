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

/// The collection view cell class for the profile screen
class ProfileCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    /// The title for the profile tile
    @IBOutlet weak var profileTileLabel: UILabel!
    
    /// The image for the profile tile
    @IBOutlet weak var profileTileImageView: UIImageView!
    
    // MARK: - Set up cell
    
    /**
     Sets up a cell according to our needs
     
     - parameter cell: The UICollectionViewCell to set up
     - parameter indexPath: The index path of the cell
     - parameter hatProvider: The object to take the values from
     
     - returns: An UICollectionViewCell
     */
    class func setUp(cell: ProfileCollectionViewCell, indexPath: IndexPath, profile: ProfileObject) -> UICollectionViewCell {
        
        // Configure the cell
        cell.profileTileLabel.text = profile.profileTileLabel
        cell.profileTileImageView.image = profile.profileTileImage
        cell.backgroundColor = self.backgroundColorOfCellForIndexPath(indexPath)
        
        // return cell
        return cell
    }
    
    // MARK: - Decide background color
    
    /**
     Decides the colof of the cell based on the index path
     
     - parameter indexPath: The index path of the cell
     - returns: The color of the cell based on the index path and the device orientation
     */
    private class func backgroundColorOfCellForIndexPath(_ indexPath: IndexPath) -> UIColor {
        
        // set the color of the cell based on indexPath.row
        if (indexPath.row % 4 == 0 || indexPath.row % 3 == 0) {
            
            return .tealColor()
        }
        
        return .rumpelDarkGray()
    }
}
