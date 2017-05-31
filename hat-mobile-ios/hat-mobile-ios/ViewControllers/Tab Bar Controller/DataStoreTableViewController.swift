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

// MARK: Class

/// A class responsible for the data store, profile, view controller
class DataStoreTableViewController: UITableViewController, UserCredentialsProtocol {
    
    // MARK: - Variables

    /// The sections of the table view
    private let sections: [[String]] = [["Name", "Info", "Contact Info"]]// ["Nationality"], ["Relationship and Household"], ["Education"]]
    /// The headers of the table view
    private let headers: [String] = ["My Profile"]
    
    /// The profile, used in PHATA table
    private var profile: HATProfileObject? = nil
    
    // MARK: - View Controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        HATPhataService.getProfileFromHAT(userDomain: userDomain, userToken: userToken, successCallback: getProfile, failCallback: logError)
    }
    
    func tableCreated(dictionary: Dictionary<String, Any>, renewedToken: String?) {
        
        HATPhataService.getProfileFromHAT(userDomain: userDomain, userToken: userToken, successCallback: getProfile, failCallback: logError)
    }
    
    private func getProfile(receivedProfile: HATProfileObject) {
        
        self.profile = receivedProfile
    }
    
    private func logError(error: HATTableError) {
        
        self.profile = HATProfileObject()
        
        switch error {
        case .tableDoesNotExist:
            
            let tableJSON = HATJSONHelper.createProfileTableJSON()
            HATAccountService.createHatTable(userDomain: userDomain, token: userToken, notablesTableStructure: tableJSON, failed: {(error) in
                
                _ = CrashLoggerHelper.hatTableErrorLog(error: error)
            })(
                
                HATAccountService.checkHatTableExistsForUploading(userDomain: userDomain, tableName: "profile", sourceName: "rumpel", authToken: userToken, successCallback: tableCreated, errorCallback: logError)
            )
        default:
            _ = CrashLoggerHelper.hatTableErrorLog(error: error)
        }
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataStoreCell", for: indexPath)
        
        return setUpCell(cell: cell, indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section < self.headers.count {
            
            return self.headers[section]
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                
                self.performSegue(withIdentifier: "dataStoreToName", sender: self)
            } else if indexPath.row == 1 {
                
                self.performSegue(withIdentifier: "dataStoreToInfoSegue", sender: self)
            } else if indexPath.row == 2 {
                
                self.performSegue(withIdentifier: "dataStoreToContactInfoSegue", sender: self)
            }
        } else if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                
                self.performSegue(withIdentifier: "dataStoreToNationalitySegue", sender: self)
            }
        } else if indexPath.section == 2 {
            
            if indexPath.row == 0 {
                
                self.performSegue(withIdentifier: "dataStoreToHouseholdSegue", sender: self)
            }
        } else if indexPath.section == 3 {
            
            if indexPath.row == 0 {
                
                self.performSegue(withIdentifier: "dataStoreToEducationSegue", sender: self)
            }
        }
    }
    
    // MARK: - Update cell
    
    /**
     Sets up the cell accordingly
     
     - parameter cell: The cell to set up
     - parameter indexPath: The index path of the cell
     - returns: The set up cell
     */
    func setUpCell(cell: UITableViewCell, indexPath: IndexPath) -> UITableViewCell {
        
        cell.textLabel?.text = self.sections[indexPath.section][indexPath.row]
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if self.profile != nil {
            
            if segue.destination is DataSourceNameTableViewController {
                
                weak var destinationVC = segue.destination as? DataSourceNameTableViewController
                
                if segue.identifier == "dataStoreToName" {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is DataStoreInfoTableViewController {
                
                weak var destinationVC = segue.destination as? DataStoreInfoTableViewController
                
                if segue.identifier == "dataStoreToInfoSegue" {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is DataStoreContactInfoTableViewController {
                
                weak var destinationVC = segue.destination as? DataStoreContactInfoTableViewController
                
                if segue.identifier == "dataStoreToContactInfoSegue" {
                    
                    destinationVC?.profile = self.profile
                }
            }
        }
    }

}
