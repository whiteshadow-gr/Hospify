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

/// The collection view cell class for onboarding screen
class OnboardingTileCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the imageview of the hat providen in the cell
    @IBOutlet weak var hatProviderImage: UIImageView!
    
    /// An IBOutlet for handling the title label of the cell
    @IBOutlet weak var titleLabel: UILabel!
    /// An IBOutlet for handling the info label of the cell
    @IBOutlet weak var infoLabel: UILabel!
    
    // MARK: - Set up cell
    
    /**
     Sets up a cell according to our needs
     
     - parameter cell: The UICollectionViewCell to set up
     - parameter indexPath: The index path of the cell
     - parameter hatProvider: The object to take the values from

     - returns: An UICollectionViewCell
     */
    class func setUp(cell: OnboardingTileCollectionViewCell, indexPath: IndexPath, hatProvider: HATProviderObject) -> UICollectionViewCell {

        // set the color of the cell accordingly based on the indexPath.row
        if (indexPath.row % 4 == 0 || indexPath.row % 3 == 0) {
            
            cell.backgroundColor = UIColor.rumpelVeryLightGray()
        } else {
            
            cell.backgroundColor = UIColor.white
        }
        
        // set cell's title
        cell.titleLabel.text = hatProvider.name
        
        // set cell's info label
        if hatProvider.price == 0 {
            
            cell.infoLabel.text = String(hatProvider.purchased) + " of " + String(hatProvider.available) + " remaining"
        } else {
            
            // format the price of the hat
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale.current
            
            let price: Double = Double(hatProvider.price / 100)
            
            cell.infoLabel.text = formatter.string(from: NSNumber(value: price))
        }
        
        // get image from url and set it to the image view
        let url: URL = URL(string: "https://hatters.hubofallthings.com/assets" + hatProvider.illustration)!
        cell.hatProviderImage.downloadedFrom(url: url)
        
        // return cell
        return cell
    }
}
