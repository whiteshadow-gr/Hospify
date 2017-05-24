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

/// A class responsible for the profile contact info, in dataStore ViewController
class DataStoreContactInfoTableViewController: UITableViewController, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// The sections of the table view
    private let sections: [[String]] = [["Email"], ["Mobile Number"], ["Home Address"], ["House/Flat Number"], ["Post Code"]]
    /// The headers of the table view
    private let headers: [String] = ["Email", "Mobile Number", "Home Address", "House/Flat Number", "Post Code"]
    
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
            
            // email
            if index == 0 {
                
                profile?.data.primaryEmail.value = cell!.textField.text!
            // Mobile
            } else if index == 1 {
                
                profile?.data.mobile.number = cell!.textField.text!
            // street name
            } else if index == 2 {
                
                profile?.data.addressDetails.street = cell!.textField.text!
            // street number
            } else if index == 3 {
                
                profile?.data.addressDetails.number = cell!.textField.text!
            // postcode
            } else if index == 4 {
                
                profile?.data.addressDetails.postCode = cell!.textField.text!
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
    
    // MARK: - View Controller functions
    
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataStoreContactInfoCell", for: indexPath) as! PhataTableViewCell
        
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

        // email
        if indexPath.section == 0 {
            
            cell.textField.text! = (profile?.data.primaryEmail.value)!
            cell.textField.keyboardType = .emailAddress
        // Mobile
        } else if indexPath.section == 1 {
            
            cell.textField.text! = (profile?.data.mobile.number)!
            cell.textField.keyboardType = .numberPad
        // street name
        } else if indexPath.section == 2 {
            
            cell.textField.text! = (profile?.data.addressDetails.street)!
        // street number
        } else if indexPath.section == 3 {
            
            cell.textField.text! = (profile?.data.addressDetails.number)!
        // address postcode
        } else if indexPath.section == 4 {
            
            cell.textField.text! = (profile?.data.addressDetails.postCode)!
        }
        return cell
    }

}
