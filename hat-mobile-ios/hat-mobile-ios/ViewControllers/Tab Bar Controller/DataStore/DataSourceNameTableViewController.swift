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

import HatForIOS

class DataSourceNameTableViewController: UITableViewController {
    
    /// The sections of the table view
    private let sections: [[String]] = [["First Name"], ["Middle Name"], ["Last Name"], ["Preffered Name"], ["Title"]]
    /// The headers of the table view
    private let headers: [String] = ["First Name", "Middle Name", "Last Name", "Preffered Name", "Title"]
    
    /// The profile, used in PHATA table
    var profile: HATProfileObject? = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataStoreNameCell", for: indexPath)
        
        return setUpCell(cell: cell, indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section < self.headers.count {
            
            return self.headers[section]
        }
        
        return nil
    }
    
    // MARK: - Update cell
    
    func setUpCell(cell: UITableViewCell, indexPath: IndexPath) -> UITableViewCell {
                
        cell.accessoryType = .none
        let tempCell = cell as! PhataTableViewCell
        
        if indexPath.section == 0 && self.profile != nil {
            
            tempCell.textField.text = self.profile?.data.personal.firstName
        } else if indexPath.section == 1 && self.profile != nil {
            
            tempCell.textField.text = self.profile?.data.personal.middleName
        } else if indexPath.section == 2 && self.profile != nil {
            
            tempCell.textField.text = self.profile?.data.personal.lastName
        } else if indexPath.section == 3 && self.profile != nil {
            
            tempCell.textField.text = self.profile?.data.personal.prefferedName
        } else if indexPath.section == 4 && self.profile != nil {
            
            tempCell.textField.text = self.profile?.data.personal.title
        }
        
        return cell
    }

}
