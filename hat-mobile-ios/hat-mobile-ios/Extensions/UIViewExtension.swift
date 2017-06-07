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
    
    // MARK: - Create floating view
    
    /**
     Adds a floating view while fetching the data plugs
     
     - parameter frame: The frame of the view
     - parameter color: The background color of the view
     - parameter cornerRadius: The corner radius of the view
     - parameter view: The view to create the floating view to
     - parameter text: The text to display in the floating view
     - parameter textColor: The color of the text in the floating view
     - parameter font: The font of the text in the floating view
     */
    class func createLoadingView(with frame: CGRect, color: UIColor, cornerRadius: CGFloat, in view: UIView, with text: String, textColor: UIColor, font: UIFont) -> UIView {
        
        // init loading view
        let tempView = UIView()
        tempView.createFloatingView(frame: frame, color: color, cornerRadius: cornerRadius)
        
        let label = UILabel().createLabel(frame: CGRect(x: 8, y: 8, width: frame.width - 16, height: frame.height - 16), text: text, textColor: textColor, textAlignment: .center, font: font)
        
        // add label to loading view
        tempView.addSubview(label)
        
        // present loading view
        view.addSubview(tempView)
        
        return tempView
    }
}
