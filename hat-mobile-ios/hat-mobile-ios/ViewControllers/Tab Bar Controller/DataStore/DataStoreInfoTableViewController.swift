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

/// A class responsible for the profile info, in dataStore ViewController
class DataStoreInfoTableViewController: UITableViewController, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// The sections of the table view
    private let sections: [[String]] = [["Age"], ["Date of Birth"], ["Gender"]]
    /// The headers of the table view
    private let headers: [String] = ["Age", "Date of Birth", "Gender"]
    
    /// The loading view pop up
    private var loadingView: UIView = UIView()
    /// A dark view covering the collection view cell
    private var darkView: UIView = UIView()
    
    /// The profile, used in PHATA table
    var profile: HATProfileObject? = nil
    
    // MARK: - IBAction

    /**
     Saves the profile to hat
     
     - parameter sender: The object that called this function
     */
    @IBAction func saveButtonAction(_ sender: Any) {
        
        self.darkView = UIView(frame: self.tableView.frame)
        self.darkView.backgroundColor = .black
        self.darkView.alpha = 0.4
        
        self.view.addSubview(self.darkView)
        
        self.loadingView = UIView.createLoadingView(with: CGRect(x: (self.view?.frame.midX)! - 70, y: (self.view?.frame.midY)! - 15, width: 140, height: 30), color: .teal, cornerRadius: 15, in: self.view, with: "Updating profile...", textColor: .white, font: UIFont(name: "OpenSans", size: 12)!)
        
        for (index, _) in self.headers.enumerated() {
            
            var cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? PhataTableViewCell
            
            if cell == nil {
                
                let indexPath = IndexPath(row: 0, section: index)
                cell = tableView.dequeueReusableCell(withIdentifier: "profileInfoCell", for: indexPath) as? PhataTableViewCell
                cell = self.setUpCell(cell: cell!, indexPath: indexPath) as? PhataTableViewCell
            }
            
            // age
            if index == 0 {
                
                profile?.data.age.group = cell!.textField.text!
            // birth
            } else if index == 1 {
                
                profile?.data.birth.date = cell!.textField.text!
            // gender
            } else if index == 2 {
                
                profile?.data.gender.type = cell!.textField.text!
            }
        }
        
        func tableExists(dict: Dictionary<String, Any>, renewedUserToken: String?) {
            
            HATPhataService.postProfile(userDomain: userDomain, userToken: userToken, hatProfile: self.profile!, successCallBack: {
                
                self.loadingView.removeFromSuperview()
                self.darkView.removeFromSuperview()
                
                _ = self.navigationController?.popViewController(animated: true)
            }, errorCallback: {error in
                
                self.loadingView.removeFromSuperview()
                self.darkView.removeFromSuperview()
                
                self.createClassicOKAlertWith(alertMessage: "There was an error posting profile", alertTitle: "Error", okTitle: "OK", proceedCompletion: {})
                
                _ = CrashLoggerHelper.hatTableErrorLog(error: error)
            })
        }
        
        HATAccountService.checkHatTableExistsForUploading(userDomain: userDomain, tableName: "profile", sourceName: "rumpel", authToken: userToken, successCallback: tableExists, errorCallback: {error in
            
            self.loadingView.removeFromSuperview()
            self.darkView.removeFromSuperview()
            
            self.createClassicOKAlertWith(alertMessage: "There was an error checking if it's possible to post the data", alertTitle: "Error", okTitle: "OK", proceedCompletion: {})
            
            _ = CrashLoggerHelper.hatTableErrorLog(error: error)
        })
    }
    
    // MARK: - View Controller funtions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataStoreInfoCell", for: indexPath) as! PhataTableViewCell
        
        return setUpCell(cell: cell, indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section < self.headers.count {
            
            return self.headers[section]
        }
        
        return nil
    }
    
    // MARK: - Update cell
    
    /**
     Sets up the cell accordingly
     
     - parameter cell: The cell to set up
     - parameter indexPath: The index path of the cell
     
     - returns: The set up cell
     */
    func setUpCell(cell: PhataTableViewCell, indexPath: IndexPath) -> UITableViewCell {
        
        cell.accessoryType = .none
        
        if indexPath.section == 0 && self.profile != nil {
            
            cell.textField.text = self.profile?.data.age.group
            cell.textField.keyboardType = .numberPad
        } else if indexPath.section == 1 && self.profile != nil {
            
            cell.textField.tag = 12
            cell.textField.text = self.profile?.data.birth.date
        } else if indexPath.section == 2 && self.profile != nil {
            
            cell.textField.tag = 15
            cell.dataSourceForPickerView = ["", "Male", "Female", "Other"]
            cell.textField.text = self.profile?.data.gender.type
        }
        
        return cell
    }

}
