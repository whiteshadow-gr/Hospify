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
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
