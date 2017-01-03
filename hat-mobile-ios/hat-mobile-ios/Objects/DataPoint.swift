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

import RealmSwift

// MARK: Class

/// The DataPoint object representation
class DataPoint : Object {
    
    // MARK: - Variables
    
    /// The latitude of the point
    dynamic var lat: Double = 0
    /// The longitude of the point
    dynamic var lng: Double = 0
    /// The accuracy of the point
    dynamic var accuracy: Double = 0
    
    /// The added point date of the point
    dynamic var dateAdded: Date = Date()
    /// The last sync date of the point
    dynamic var lastSynced: Date? = nil // optional..can be nil
}
