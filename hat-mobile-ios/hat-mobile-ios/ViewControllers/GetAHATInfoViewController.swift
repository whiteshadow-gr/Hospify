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

class GetAHATInfoViewController: UIViewController {
    
    // MARK: - Variables
    
    var hatProvider: HATProviderObject? = nil
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var hatProviderImage: UIImageView!
    
    @IBOutlet weak var hatProviderTitle: UILabel!
    @IBOutlet weak var hatProviderInfo: UILabel!
    @IBOutlet weak var hatProviderDetailedInfo: UILabel!
    @IBOutlet weak var hatProviderFeaturesLabel: UILabel!
    @IBOutlet weak var hatProviderFeaturesListLabel: UILabel!

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: - IBActions
    
    @IBAction func signUpAction(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name("hideView"), object: "1")
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name("hideView"), object: nil)
    }
    
    // MARK: - View Controller methods

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cancelButton.imageView?.image = cancelButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
        cancelButton.tintColor = UIColor.black
        
        if (hatProvider != nil) {
            
            self.hatProviderImage.image = (hatProvider?.hatProviderImage)!
            self.hatProviderTitle.text = hatProvider?.name
            self.hatProviderInfo.text = hatProvider?.category.description
            self.hatProviderDetailedInfo.text = hatProvider?.description
            self.hatProviderDetailedInfo.sizeToFit()
            self.hatProviderInfo.sizeToFit()
            
            let features: NSMutableAttributedString = NSMutableAttributedString(string: "")
            for (index, string) in (hatProvider?.features)!.enumerated() {
                
                features.append(NSAttributedString(string: string))
                
                if (index < (hatProvider?.features.count)! - 1) {
                    
                    features.append(NSAttributedString(string: "\n" + "\u{2022}" + "\n"))
                }
            }
            
            self.hatProviderFeaturesListLabel.attributedText = features
            
            // format title label
            let textAttributesTitle = [
                NSForegroundColorAttributeName: UIColor.white,
                NSStrokeColorAttributeName: UIColor.white,
                NSFontAttributeName: UIFont(name: "Open Sans", size: 14)!,
                NSStrokeWidthAttributeName: -1.0
                ] as [String : Any]
            
            let textAttributes = [
                NSForegroundColorAttributeName: UIColor.white,
                NSStrokeColorAttributeName: UIColor.white,
                NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 14)!,
                NSStrokeWidthAttributeName: -1.0
                ] as [String : Any]
            
            let partOne = NSAttributedString(string: "SIGN ME UP ", attributes: textAttributesTitle)
            let partTwo = NSAttributedString(string: "FREE", attributes: textAttributes)
            let combination = NSMutableAttributedString()
            
            combination.append(partOne)
            combination.append(partTwo)
            
            self.signUpButton.setAttributedTitle(combination, for: .normal)
        }
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
