/** Copyright (C) 2016 HAT Data Exchange Ltd
 * SPDX-License-Identifier: AGPL-3.0
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * RumpelLite is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License
 * as published by the Free Software Foundation, version 3 of
 * the License.
 *
 * RumpelLite is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
 * the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General
 * Public License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
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
