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

/// Extends UITAbleView. Manage the rendering of DataPoints
class DataPointsTableView: UITableView, UITableViewDelegate, UITableViewDataSource {

    
    var dataResults : Results<DataPoint>!
    let basicCellIdentifier = "DataPointTableViewCell"

    /**
     Initialisation code when first constructed.
     */
    override func awakeFromNib() {
        delegate = self
        dataSource = self
        
        let startOfToday = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
        let predicate = NSPredicate(format: "dateAdded >= %@", startOfToday)
        dataResults = RealmHelper.GetResults(predicate)?.sorted("dateAdded", ascending: false)
        reloadData()
    }
    
    // MARK: UITableViewDataSource
    
    /**
     Part of UITableViewDataSource.
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataResults.count
    }
    
    /**
     Part of UITableViewDataSource.
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : DataPointTableViewCell? = tableView.dequeueReusableCellWithIdentifier(basicCellIdentifier) as! DataPointTableViewCell?
        
        if (cell == nil) {
            cell = DataPointTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: basicCellIdentifier)
        }
        
        let dataPoint:DataPoint = dataResults[indexPath.row]
        
        if let latitude:Double = dataPoint.lat
        {
            if let longitude:Double = dataPoint.lng
            {
                cell!.labelLatitude.text = String(latitude) + ", " + String(longitude) + ", " + String(dataPoint.accuracy)
            }
        }
        
        if let time:NSDate = dataPoint.dateAdded {
            cell!.labelDateAdded.text = "Added " + Helper.getDateString(time)
        }
        
        // last sync date
        if let lastSynced:NSDate = dataPoint.lastSynced {
            cell!.labelSyncDate.text = "Synced " + Helper.getDateString(lastSynced)
            cell!.labelSyncDate.textColor = Constants.Colours.AppBase
        }else{
            cell?.labelSyncDate.text = NSLocalizedString("not_synced_label", comment:  "")
            cell!.labelSyncDate.textColor = UIColor.redColor()
        }

        return cell!
    }
    
    
    // MARK: UITableViewDelegate
    
    /**
     Part of UITableViewDelegate.
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // do nothing
    }
    
    
}
