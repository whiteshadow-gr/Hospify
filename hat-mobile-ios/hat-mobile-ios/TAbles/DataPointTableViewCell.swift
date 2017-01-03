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

/// The data points table view cell class
class DataPointTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets

    /// An IBOutlet for handling the latitude label of the cell
    @IBOutlet weak var labelLatitude: UILabel!
    /// An IBOutlet for handling the date label of the cell
    @IBOutlet weak var labelDateAdded: UILabel!
    /// An IBOutlet for handling the sync label of the cell
    @IBOutlet weak var labelSyncDate: UILabel!
}
