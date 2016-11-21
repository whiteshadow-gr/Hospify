//
//  KeyboardHelper.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 15/11/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import UIKit

class KeyboardHelper: NSObject {
    
    public func keyboardWillShow(sender: NSNotification) {
        //self.view.frame.origin.y = -150
        print(sender.object!)
    }
    
    public func keyboardWillHide(sender: NSNotification) {
        //self.view.frame.origin.y = 0
        print("yes")
    }

}
