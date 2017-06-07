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

/// A class responsible for handling the Data Offers Collection View cell
class DataOffersCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the imageView
    @IBOutlet weak var imageView: UIImageView!
    
    /// An IBOutlet for handling the title UILabel
    @IBOutlet weak var titleLabel: UILabel!
    /// An IBOutlet for handling the details UILabel
    @IBOutlet weak var detailsLabel: UILabel!
    
}
