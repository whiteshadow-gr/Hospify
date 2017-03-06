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

// MARK: Extension

extension UIView {
    
    // MARK: - Create floating view
    
    /**
     Creates a pop up view to present it to the view controller
     
     - parameter frame: The frame of the view
     - parameter color: The background color of the view
     - parameter cornerRadius: The corner radius of the view
     */
    func createFloatingView(frame: CGRect, color: UIColor, cornerRadius: CGFloat) {
        
        // init loading view
        self.frame = frame
        self.backgroundColor = color
        self.layer.cornerRadius = cornerRadius
    }
}
