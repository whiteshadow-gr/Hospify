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
     User taped on sign up button. Open URL or hide pop up view depending on the data
     
     - parameter sender: The object that called this method
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
            
            NotificationCenter.default.post(name: NSNotification.Name(Constants.NotificationNames.hideFirstOnboardingView.rawValue), object: "1")
        }
    }
    
    /**
     User taped on cancel button, hide pop up view
     
     - parameter sender: The object that called this method
     */
    @IBAction func cancelButtonAction(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name(Constants.NotificationNames.hideFirstOnboardingView.rawValue), object: nil)
    }
    
    // MARK: - View Controller methods

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // set up cancel button
        self.cancelButton.imageView?.image = cancelButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
        self.cancelButton.tintColor = UIColor.black
        
        // if we have a passed value from parent view controler, set up the view with this value
        if (self.hatProvider != nil) {
            
            // assigning values to objects
            self.hatProviderImage.image = self.hatProvider?.hatProviderImage!
            self.hatProviderTitle.text = self.hatProvider?.name
            self.hatProviderInfo.text = self.hatProvider?.category.description
            self.hatProviderInfo.layoutIfNeeded()
            self.hatProviderDetailedInfo.text = self.hatProvider?.description
            self.hatProviderDetailedInfo.sizeToFit()
            
            if (self.hatProvider?.price)! > 0 && self.hatProvider?.kind.kind != "External" {
                
                self.signUpButton.setAttributedTitle("SIGN ME UP".createTextAttributes(foregroundColor: .white, strokeColor: .white, font: UIFont(name: Constants.fontNames.openSans.rawValue, size: 14)!), for: .normal)
            } else if self.hatProvider?.kind.kind == "External" {
                
                let buttonName = "Learn more about " + (self.hatProvider?.name)!
                self.signUpButton.setAttributedTitle(buttonName.createTextAttributes(foregroundColor: .white, strokeColor: .white, font: UIFont(name: Constants.fontNames.openSans.rawValue, size: 14)!), for: .normal)
            } else {
                
                let partOne = "SIGN ME UP".createTextAttributes(foregroundColor: .white, strokeColor: .white, font: UIFont(name: Constants.fontNames.openSans.rawValue, size: 14)!)
                let partTwo = "FREE".createTextAttributes(foregroundColor: .white, strokeColor: .white, font: UIFont(name: Constants.fontNames.openSansBold.rawValue, size: 14)!)
                let combination = partOne.combineWith(attributedText: partTwo)
                
                self.signUpButton.setAttributedTitle(combination, for: .normal)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
