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

import RealmSwift

// MARK: Class

/// The data points to upload or that has been uploaded view controller
class DataViewController: UIViewController {
    
    // MARK: - IBOutlet

    /// An IBOutlet for handling the table view
    @IBOutlet weak var dataTableView: DataPointsTableView!
    
    // MARK: - IBAction
    
    /**
     Purge buton pressed event
     
     - parameter sender: UIBarButtonItem
     */
    @IBAction func buttonPurge(_ sender: UIBarButtonItem) {
        
        // create alert
        self.createClassicAlertWith(alertMessage: NSLocalizedString("purge_message_label", comment:  "purge message"),
                                    alertTitle: NSLocalizedString("purge_label", comment:  "purge"),
                                    cancelTitle: NSLocalizedString("no_label", comment:  "no"),
                                    proceedTitle: NSLocalizedString("yes_label", comment:  "yes"),
                                    proceedCompletion: {
                                                            () -> Void in
                                                            
                                                            if (RealmHelper.Purge(nil)) {
                                                                
                                                                self.dataTableView.reloadData()
                                                            }
                                                        },
                                    cancelCompletion: {() -> Void in return})}
    
    // MARK: - View controller functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // view controller title
        self.title = NSLocalizedString("data_label", comment:  "data title")
    }
}
