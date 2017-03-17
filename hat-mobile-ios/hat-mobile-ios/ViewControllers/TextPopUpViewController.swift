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

// MARK: Class

class TextPopUpViewController: UIViewController {
    
    // MARK: - Variables
    
    var textToShow: String = ""
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var textLabel: UILabel!
    
    // MARK: - IBActions
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        
        AnimationHelper.animateView(self.view,
                                    duration: 0.2,
                                    animations: {() -> Void in
                                        
                                        self.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height) },
                                    completion: {(bool: Bool) -> Void in
                                        
                                        self.removeViewController()
                                        NotificationCenter.default.post(name: NSNotification.Name("hideDataServicesInfo"), object: nil)

        })
    }
    
    // MARK: View controller methods

    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.textLabel.text = textToShow
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     - parameter <#Parameter#>: <#Parameter description#>
     - returns: <#Returns#>
     */
    class func customInit(stringToShow: String, from storyBoard: UIStoryboard) -> TextPopUpViewController? {
        
        let textPopUpViewController = storyBoard.instantiateViewController(withIdentifier: "textPopUpViewController") as? TextPopUpViewController
        textPopUpViewController?.textToShow = stringToShow
        textPopUpViewController?.view.alpha = 0.7
        
        return textPopUpViewController
    }

}
