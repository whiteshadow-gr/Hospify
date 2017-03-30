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

extension UIAlertController {
    
    // MARK: - Functions

    /**
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     */
    func addActions(actions: [UIAlertAction]) {
        
        for action in actions {
            
          self.addAction(action)
        }
    }
    
    /**
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     - parameter <#Parameter#>: <#Parameter description#>
     */
    func addiPadSupport(sourceRect: CGRect, sourceView: UIView) {
        
        // if user is on ipad show as a pop up
        if UI_USER_INTERFACE_IDIOM() == .pad {
            
            self.popoverPresentationController?.sourceRect = sourceRect
            self.popoverPresentationController?.sourceView = sourceView
        }
    }
    
    /**
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     - parameter <#Parameter#>: <#Parameter description#>
     */
    func addiPadSupport(barButtonItem: UIBarButtonItem, sourceView: UIView) {
        
        // if user is on ipad show as a pop up
        if UI_USER_INTERFACE_IDIOM() == .pad {
            
            self.popoverPresentationController?.barButtonItem = barButtonItem
            self.popoverPresentationController?.sourceView = sourceView
        }
    }
}
