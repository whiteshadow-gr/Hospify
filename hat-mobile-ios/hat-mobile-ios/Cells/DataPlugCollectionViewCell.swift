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

/// The collection view cell class for data plugs screen
class DataPlugCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    /// The image for the data plug
    @IBOutlet weak var dataPlugImage: UIImageView!
    /// The checkmark image for the data plug. It's hidden if it's not active
    @IBOutlet weak var checkMarkImage: UIImageView!
    
    /// The title for the data plug
    @IBOutlet weak var dataPlugTitleLabel: UILabel!
    /// Some details for the data plug
    @IBOutlet weak var dataPlugDetailsLabel: UILabel!
    
    // MARK: - Set up cell
    
    /**
     Sets up a cell according to our needs
     
     - parameter cell: The UICollectionViewCell to set up
     - parameter indexPath: The index path of the cell
     - parameter hatProvider: The object to take the values from
     
     - returns: An UICollectionViewCell
     */
    class func setUp(cell: DataPlugCollectionViewCell, indexPath: IndexPath, dataPlug: DataPlugObject, orientation: UIInterfaceOrientation) -> UICollectionViewCell {
        
        // Configure the cell
        cell.dataPlugTitleLabel.text = dataPlug.name
        cell.dataPlugDetailsLabel.text = dataPlug.description
        cell.dataPlugImage.downloadedFrom(url: URL(string: dataPlug.illustrationUrl)!)
        
        if dataPlug.showCheckMark == true {
            
            cell.checkMarkImage.isHidden = false
        }
        
        // check if device is in portrait mode, 3 tiles per row vs 2
        if orientation.isPortrait {
            
            // create this zebra like color based on the index of the cell
            if (indexPath.row % 4 == 0 || indexPath.row % 3 == 0) {
                
                cell.backgroundColor = UIColor.rumpelVeryLightGray()
            } else {
                
                cell.backgroundColor = UIColor.white
            }
        } else {
            
            // create this zebra like color based on the index of the cell
            if (indexPath.row % 2 == 0 ) {
                
                cell.backgroundColor = UIColor.rumpelVeryLightGray()
            } else {
                
                cell.backgroundColor = UIColor.white
            }
        }
        
        // return cell
        return cell
    }
}
