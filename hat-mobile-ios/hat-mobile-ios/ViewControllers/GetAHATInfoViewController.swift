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

/// Get A hat info view controller, used in onboarding of new users. A pop up view in GetAHATViewController
class GetAHATInfoViewController: UIViewController {
    
    // MARK: - Variables
    
    /// the HAT provider object
    var hatProvider: HATProviderObject? = nil
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the hatProviderImage image view
    @IBOutlet weak var hatProviderImage: UIImageView!
    
    /// An IBOutlet for handling the hatProviderDetailedInfo label
    @IBOutlet weak var hatProviderDetailedInfo: UITextView!
    /// An IBOutlet for handling the hatProviderTitle label
    @IBOutlet weak var hatProviderTitle: UILabel!
    /// An IBOutlet for handling the hatProviderInfo label
    @IBOutlet weak var hatProviderInfo: UITextView!

    /// An IBOutlet for handling the signUpButton button
    @IBOutlet weak var signUpButton: UIButton!
    /// An IBOutlet for handling the cancelButton button
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: - IBActions
    
    /**
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     */
    @IBAction func signUpAction(_ sender: Any) {
        
        if self.hatProvider?.name == "HALL Free HAT" {
            
            if let url = URL(string: "http://hubofallthings.com/hall/") {
                
                UIApplication.shared.openURL(url)
            }
        } else if self.hatProvider?.kind.kind == "External" {
            
            if let url = URL(string: (self.hatProvider?.kind.link)!) {
                
                UIApplication.shared.openURL(url)
            }
        } else {
            
            NotificationCenter.default.post(name: NSNotification.Name("hideView"), object: "1")
        }
    }
    
    /**
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     */
    @IBAction func cancelButtonAction(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name("hideView"), object: nil)
    }
    
    // MARK: - View Controller methods

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // set up cancel button
        cancelButton.imageView?.image = cancelButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
        cancelButton.tintColor = UIColor.black
        
        // if we have a passed value from parent view controler, set up the view with this value
        if (hatProvider != nil) {
            
            self.hatProviderImage.image = (hatProvider?.hatProviderImage)!
            self.hatProviderTitle.text = hatProvider?.name
            self.hatProviderInfo.text = hatProvider?.category.description
            self.hatProviderInfo.layoutIfNeeded()
            self.hatProviderDetailedInfo.text = hatProvider?.description
            self.hatProviderDetailedInfo.sizeToFit()
            
            let features: NSMutableAttributedString = NSMutableAttributedString(string: "")
            for (index, string) in (hatProvider?.features)!.enumerated() {
                
                features.append(NSAttributedString(string: string))
                
                if (index < (hatProvider?.features.count)! - 1) {
                    
                    features.append(NSAttributedString(string: "\n" + "\u{2022}" + "\n"))
                }
            }
                        
            // format title label
            let textAttributesTitle = [
                NSForegroundColorAttributeName: UIColor.white,
                NSStrokeColorAttributeName: UIColor.white,
                NSFontAttributeName: UIFont(name: "OpenSans", size: 14)!,
                NSStrokeWidthAttributeName: -1.0
                ] as [String : Any]
            
            let textAttributes = [
                NSForegroundColorAttributeName: UIColor.white,
                NSStrokeColorAttributeName: UIColor.white,
                NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 14)!,
                NSStrokeWidthAttributeName: -1.0
                ] as [String : Any]
            
            if (self.hatProvider?.price)! > 0 && self.hatProvider?.kind.kind != "External" {
                
                self.signUpButton.setAttributedTitle(NSAttributedString(string: "SIGN ME UP", attributes: textAttributesTitle), for: .normal)
            } else if self.hatProvider?.kind.kind == "External" {
                
                let buttonName = "Learn more about " + (self.hatProvider?.name)!
                self.signUpButton.setAttributedTitle(NSAttributedString(string: buttonName, attributes: textAttributesTitle), for: .normal)
            } else {
                
                let partOne = NSAttributedString(string: "SIGN ME UP ", attributes: textAttributesTitle)
                let partTwo = NSAttributedString(string: "FREE", attributes: textAttributes)
                let combination = NSMutableAttributedString()
                
                combination.append(partOne)
                combination.append(partTwo)
                
                self.signUpButton.setAttributedTitle(combination, for: .normal)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
