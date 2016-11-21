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
class DataViewController: BaseViewController {
    
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
        let alert = UIAlertController(title: NSLocalizedString("purge_label", comment:  "purge"), message: NSLocalizedString("purge_message_label", comment:  "purge message"), preferredStyle: .alert)
        
        // create actions
        let yesButtonOnAlertAction = UIAlertAction(title: NSLocalizedString("yes_label", comment:  "yes"), style: .default) {
            (action) -> Void in
            
            if (RealmHelper.Purge()) {
                
                self.dataTableView.reloadData()
            }
        }
        
        // add the actions
        alert.addAction(yesButtonOnAlertAction)
        alert.addAction(UIAlertAction(title: NSLocalizedString("no_label", comment:  "no"), style: UIAlertActionStyle.default, handler: nil))
        
        // present view controller
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - View controller functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // view controller title
        self.title = NSLocalizedString("data_label", comment:  "data title")
    }
}
