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

// MARK: Extension

extension UIButton {
    
    // MARK: - Extension's functions
    
    /**
     adds a border to the button
     
     - parameter width: The width as a CGFloat
     - parameter color: The color of the border
     */
    func addBorderToButton(width: CGFloat, color: UIColor) -> Void {
        
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
}
