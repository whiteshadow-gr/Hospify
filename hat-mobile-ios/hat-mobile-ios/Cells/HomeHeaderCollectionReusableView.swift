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

/// The reusable header view for the collection view cell class for home screen
class HomeHeaderCollectionReusableView: UICollectionReusableView {
    
    // MARK: - IBOutlets
    
    /// The header title
    @IBOutlet weak var headerTitle: UILabel!
    
    /// The header help image
    @IBOutlet weak var headerHelpImage: UIImageView!
}
