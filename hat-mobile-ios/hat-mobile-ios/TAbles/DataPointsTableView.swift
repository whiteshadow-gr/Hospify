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

/// Extends UITAbleView. Manage the rendering of DataPoints
class DataPointsTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Variables
    
    /// the data points from Realm
    private var dataResults: Results<DataPoint>!
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
        dataResults = RealmHelper.getResults(predicate)?.sorted(byKeyPath: "dateAdded", ascending: false)
        reloadData()
    }
    
    // MARK: - UITableView methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: DataPointTableViewCell? = tableView.dequeueReusableCell(withIdentifier: basicCellIdentifier) as! DataPointTableViewCell?
        
        if (cell == nil) {
            
            cell = DataPointTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: basicCellIdentifier)
        }
        
        let dataPoint:DataPoint = dataResults[indexPath.row]
        
        cell!.labelLatitude.text = String(dataPoint.lat) + ", " + String(dataPoint.lng) + ", " + String(dataPoint.accuracy)
        cell!.labelDateAdded.text = "Added " + FormatterHelper.getDateString(dataPoint.dateAdded)
        
        // last sync date
        if let lastSynced:Date = dataPoint.lastSynced as Date? {
            
            cell!.labelSyncDate.text = "Synced " + FormatterHelper.getDateString(lastSynced)
            cell!.labelSyncDate.textColor = Constants.Colours.AppBase
        } else {
            
            cell?.labelSyncDate.text = NSLocalizedString("not_synced_label", comment:  "")
            cell!.labelSyncDate.textColor = UIColor.red
        }

        return cell!
    }
}
