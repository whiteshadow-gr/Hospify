//
//  UIElementsFormatter.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 26/11/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

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
