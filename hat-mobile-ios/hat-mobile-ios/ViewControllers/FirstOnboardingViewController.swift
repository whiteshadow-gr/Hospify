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

class FirstOnboardingViewController: UIViewController {
    
    var pageIndex = 0

    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var messages: UILabel!
    
    @IBOutlet weak var learnMoreButton: UIButton!
    
    @IBAction func clearButtonAction(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name("hidePageViewContoller"), object: nil)
    }
    
    @IBAction func learnMoreButtonAction(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let learnMoreObject = LearnMoreObject(pageNumber: 20 + pageIndex)
        
        if pageIndex == 0 {
            
            // format title label
            let textAttributesTitle = [
                NSForegroundColorAttributeName: UIColor.white,
                NSStrokeColorAttributeName: UIColor.white,
                NSFontAttributeName: UIFont(name: "Open Sans Condensed", size: 30)!,
                NSStrokeWidthAttributeName: -1.0
                ] as [String : Any]
            let textAttributes = [
                NSForegroundColorAttributeName: UIColor.darkGray,
                NSStrokeColorAttributeName: UIColor.darkGray,
                NSFontAttributeName: UIFont(name: "OpenSans", size: 16)!,
                NSStrokeWidthAttributeName: -1.0
                ] as [String : Any]
            
            let partOne = NSAttributedString(string: learnMoreObject.title + "\n", attributes: textAttributesTitle)
            let partTwo = NSAttributedString(string: learnMoreObject.info, attributes: textAttributes)
            let combination = NSMutableAttributedString()
            
            combination.append(partOne)
            combination.append(partTwo)
            
            self.messages.attributedText = combination
            self.learnMoreButton.isHidden = true
            self.image.image = learnMoreObject.image
        } else if pageIndex == 1 {
            
            // format title label
            let textAttributesTitle = [
                NSForegroundColorAttributeName: UIColor.white,
                NSStrokeColorAttributeName: UIColor.white,
                NSFontAttributeName: UIFont(name: "Open Sans Condensed", size: 30)!,
                NSStrokeWidthAttributeName: -1.0
                ] as [String : Any]
            let textAttributes = [
                NSForegroundColorAttributeName: UIColor.darkGray,
                NSStrokeColorAttributeName: UIColor.darkGray,
                NSFontAttributeName: UIFont(name: "OpenSans", size: 16)!,
                NSStrokeWidthAttributeName: -1.0
                ] as [String : Any]
            
            let partOne = NSAttributedString(string: learnMoreObject.title + "\n", attributes: textAttributesTitle)
            let partTwo = NSAttributedString(string: learnMoreObject.info, attributes: textAttributes)
            let combination = NSMutableAttributedString()
            
            combination.append(partOne)
            combination.append(partTwo)
            
            self.messages.attributedText = combination
            self.learnMoreButton.isHidden = true
            self.image.image = learnMoreObject.image
        } else if pageIndex == 2 {
            
            // format title label
            let textAttributesTitle = [
                NSForegroundColorAttributeName: UIColor.white,
                NSStrokeColorAttributeName: UIColor.white,
                NSFontAttributeName: UIFont(name: "Open Sans Condensed", size: 30)!,
                NSStrokeWidthAttributeName: -1.0
                ] as [String : Any]
            let textAttributes = [
                NSForegroundColorAttributeName: UIColor.darkGray,
                NSStrokeColorAttributeName: UIColor.darkGray,
                NSFontAttributeName: UIFont(name: "OpenSans", size: 16)!,
                NSStrokeWidthAttributeName: -1.0
                ] as [String : Any]
            
            let partOne = NSAttributedString(string: learnMoreObject.title + "\n", attributes: textAttributesTitle)
            let partTwo = NSAttributedString(string: learnMoreObject.info, attributes: textAttributes)
            let combination = NSMutableAttributedString()
            
            combination.append(partOne)
            combination.append(partTwo)
            
            self.messages.attributedText = combination
            self.learnMoreButton.isHidden = false
            self.learnMoreButton.setTitle("GET STARTED", for: .normal)
            self.learnMoreButton.addBorderToButton(width: 1, color: .white)
            self.image.image = learnMoreObject.image
        } else if pageIndex == 3 {
            
            // format title label
            let textAttributesTitle = [
                NSForegroundColorAttributeName: UIColor.white,
                NSStrokeColorAttributeName: UIColor.white,
                NSFontAttributeName: UIFont(name: "Open Sans Condensed", size: 30)!,
                NSStrokeWidthAttributeName: -1.0
                ] as [String : Any]
            
            self.messages.attributedText = NSAttributedString(string: learnMoreObject.title + "\n", attributes: textAttributesTitle)
            self.learnMoreButton.isHidden = false
            self.learnMoreButton.setTitle("SET UP MY PHATA", for: .normal)
            self.learnMoreButton.addBorderToButton(width: 1, color: .white)
            self.image.image = learnMoreObject.image
        }
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
