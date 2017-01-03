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
}
