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

extension UIApplication {
    
    // MARK: - Get top view controller
    
    /**
     Returns the top View controller currently in stack
     
     - parameter controller: The controller to search on
     - returns: The top UIViewController
     */
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let navigationController = controller as? UINavigationController {
            
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController {
            
            if let selected = tabController.selectedViewController {
                
                return topViewController(controller: selected)
            }
        }
        
        if let presented = controller?.presentedViewController {
            
            return topViewController(controller: presented)
        }
        
        return controller
    }

}
