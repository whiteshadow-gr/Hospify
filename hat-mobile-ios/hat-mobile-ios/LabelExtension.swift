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

extension UILabel {
    
    func createLabel(frame: CGRect, text: String, textColor: UIColor, textAlignment: NSTextAlignment, font: UIFont?) -> UILabel {
        
        // create label to show in loading view
        self.frame = frame
        self.text = text
        self.numberOfLines = 0
        self.textColor = textColor
        self.font = font
        self.textAlignment = textAlignment
        
        return self
    }
}
