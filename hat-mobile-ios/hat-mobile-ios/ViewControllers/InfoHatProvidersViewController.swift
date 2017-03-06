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

/// The class responsible for showing info about hat providers
class InfoHatProvidersViewController: UIViewController {
    
    // MARK: - IBOutlets

    /// An IBOutlet for handling the textLabel we want to show
    @IBOutlet weak var textLabel: UILabel!
    
    // MARK: - IBActions
    
    /**
     Hides the pop up info view controller via a notification
     
     - parameter sender: The object called this method
     */
    @IBAction func cancelButtonAction(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name(Constants.NotificationNames.hideInfoHATProvider.rawValue), object: nil)
    }
    
    // MARK: - View controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.textLabel.text = "All HAT providers are certified by the HAT Community Foundation to have achieved the required confidentiality, privacy and security credentials. Each HAT provider has its own unique domain name for your personal HAT address"
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
