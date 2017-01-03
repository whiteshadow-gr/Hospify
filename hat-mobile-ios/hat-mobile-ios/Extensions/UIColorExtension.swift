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

extension UIColor {

    /**
     Returns the teal color
     */
    class func tealColor() -> UIColor {
        
        return UIColor.init(colorLiteralRed: 0/255, green: 150/255, blue: 136/255, alpha: 1)
    }
    
    /**
     Returns the light gray color used in rumpel
     */
    class func rumpelLightGray() -> UIColor {
        
        return UIColor.init(colorLiteralRed: 51/255, green: 74/255, blue: 79/255, alpha: 1)
    }
    
    /**
     Returns the dark gray color used in rumpel
     */
    class func rumpelDarkGray() -> UIColor {
        
        return UIColor.init(colorLiteralRed: 29/255, green: 49/255, blue: 53/255, alpha: 1)
    }
}
