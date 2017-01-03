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

/// Extends UITAbleView. Manage the rendering of DataPoints
class DataPointsTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Variables
    
    /// the data points from Realm
    private var dataResults : Results<DataPoint>!
    /// the cell identifier
    private let basicCellIdentifier = "DataPointTableViewCell"
    
    // MARK: - View Controller delegate methods

    /**
     Initialisation code when first constructed.
     */
    override func awakeFromNib() {
        
        delegate = self
        dataSource = self
        
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let predicate = NSPredicate(format: "dateAdded >= %@", startOfToday as CVarArg)
        dataResults = RealmHelper.GetResults(predicate)?.sorted(byProperty: "dateAdded", ascending: false)
        reloadData()
    }
    
    // MARK: - UITableView methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : DataPointTableViewCell? = tableView.dequeueReusableCell(withIdentifier: basicCellIdentifier) as! DataPointTableViewCell?
        
        if (cell == nil) {
            
            cell = DataPointTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: basicCellIdentifier)
        }
        
        let dataPoint:DataPoint = dataResults[indexPath.row]
        
        cell!.labelLatitude.text = String(dataPoint.lat) + ", " + String(dataPoint.lng) + ", " + String(dataPoint.accuracy)
        
        cell!.labelDateAdded.text = "Added " + Helper.getDateString(dataPoint.dateAdded)
        
        
        // last sync date
        if let lastSynced:Date = dataPoint.lastSynced as Date? {
            
            cell!.labelSyncDate.text = "Synced " + Helper.getDateString(lastSynced)
            cell!.labelSyncDate.textColor = Constants.Colours.AppBase
        } else {
            
            cell?.labelSyncDate.text = NSLocalizedString("not_synced_label", comment:  "")
            cell!.labelSyncDate.textColor = UIColor.red
        }

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // do nothing
    }
}
