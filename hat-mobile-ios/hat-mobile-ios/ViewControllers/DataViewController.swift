/** Copyright (C) 2016 HAT Data Exchange Ltd
 * SPDX-License-Identifier: AGPL-3.0
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * RumpelLite is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License
 * as published by the Free Software Foundation, version 3 of
 * the License.
 *
 * RumpelLite is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
 * the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General
 * Public License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
 */

import UIKit
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
                                                            
                                                            if (RealmHelper.Purge()) {
                                                                
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
