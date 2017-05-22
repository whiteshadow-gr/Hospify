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

/// The class responsible for the selected images to upload in the shareOptionsViewController
class ShareOptionsSelectedImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    /// The selected image to upload
    @IBOutlet weak var selectedImage: UIImageView!
    
    /// A button to remove the image from uploading
    @IBOutlet weak var cancelButton: UIButton!
    
    /// A ring progress circe bar to track progress of download
    @IBOutlet weak var ringProgressCircle: RingProgressCircle!
    
    // MARK: - IBActions
    
    /**
     Removes the image from the uploading list
     
     - parameter sender: The object that called this method
     */
    @IBAction func cancelButtonAction(_ sender: Any) {
        
        self.selectedImage.image = nil
    }
    
}
