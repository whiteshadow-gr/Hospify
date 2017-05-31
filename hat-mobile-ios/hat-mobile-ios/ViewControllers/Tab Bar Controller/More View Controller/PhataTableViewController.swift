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

/// A class responsible for the phata UITableViewController of the more tab bar
class PhataTableViewController: UITableViewController, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// The sections of the table view
    private let sections: [[String]] = [["PHATA"], ["Email Address", "Mobile Number", "Address"], ["Full Name", "Picture"], ["Emergency Contact"], ["About"], ["Social Links"]]
    /// The headers of the table view
    private let headers: [String] = ["PHATA", "Contact Info", "Profile", "Emergency Contact", "About", "Social Links"]
    
    /// User's profile passed on from previous view controller
    var profile: HATProfileObject? = nil
    
    var isProfileDownloaded: Bool = false
    
    // MARK: - Update profile responses
    
    private func getProfile(receivedProfile: HATProfileObject) {
        
        self.profile = receivedProfile
        
        self.isProfileDownloaded = true
        
        self.tableView.reloadData()
    }
    
    func tableCreated(dictionary: Dictionary<String, Any>, renewedToken: String?) {
        
        HATPhataService.getProfileFromHAT(userDomain: userDomain, userToken: userToken, successCallback: getProfile, failCallback: logError)
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
    
    // MARK: - View Controller methods

    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
        HATPhataService.getProfileFromHAT(userDomain: userDomain, userToken: userToken, successCallback: getProfile, failCallback: logError)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if self.isProfileDownloaded {
            
            return true
        }
        
        return false
    }

    // MARK: - Table view methods

    override func numberOfSections(in tableView: UITableView) -> Int {

        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.sections[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "phataCell", for: indexPath)

        return self.setUpCell(cell, indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.headers[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.profile != nil && self.isProfileDownloaded {
            
            if indexPath.section == 0 {
                
                if indexPath.row == 0 {
                    
                    self.performSegue(withIdentifier: "phataSettingsSegue", sender: self)
                }
            } else if indexPath.section == 1 {
                
                if indexPath.row == 0 {
                    
                    self.performSegue(withIdentifier: "phataToEmailSegue", sender: self)
                } else if indexPath.row == 1 {
                    
                    self.performSegue(withIdentifier: "phataToPhoneSegue", sender: self)
                } else if indexPath.row == 2 {
                    
                    self.performSegue(withIdentifier: "phataToAddressSegue", sender: self)
                }
            } else if indexPath.section == 2 {
                
                if indexPath.row == 0 {
                    
                    self.performSegue(withIdentifier: "phataToNameSegue", sender: self)
                } else if indexPath.row == 1 {
                    
                    self.performSegue(withIdentifier: "phataToProfilePictureSegue", sender: self)
                }
            } else if indexPath.section == 3 {
                
                self.performSegue(withIdentifier: "phataToEmergencyContactSegue", sender: self)
            } else if indexPath.section == 4 {
                
                self.performSegue(withIdentifier: "phataToAboutSegue", sender: self)
            } else if indexPath.section == 5 {
                
                self.performSegue(withIdentifier: "phataToSocialLinksSegue", sender: self)
            }
        } else {
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: - Set up cell
    
    /**
     Updates and formats the cell accordingly
     
     - parameter cell: The UITableViewCell to update and format
     - parameter indexPath: The indexPath of the cell
     
     - returns: A UITableViewCell cell already updated and formatted accordingly
     */
    private func setUpCell(_ cell: UITableViewCell, indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            cell.textLabel?.text = self.userDomain
            cell.accessoryType = .disclosureIndicator
        } else {
            
            cell.textLabel?.text = self.sections[indexPath.section][indexPath.row]
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if self.profile != nil && self.isProfileDownloaded {
            
            if segue.destination is NameTableViewController {
                
                weak var destinationVC = segue.destination as? NameTableViewController
                
                if segue.identifier == "phataToNameSegue" {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is ProfileInfoTableViewController {
                
                weak var destinationVC = segue.destination as? ProfileInfoTableViewController
                
                if segue.identifier == "phataToProfileInfoSegue" {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is EmailTableViewController {
                
                weak var destinationVC = segue.destination as? EmailTableViewController
                
                if segue.identifier == "phataToEmailSegue" {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is PhoneTableViewController {
                
                weak var destinationVC = segue.destination as? PhoneTableViewController
                
                if segue.identifier == "phataToPhoneSegue" {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is AboutTableViewController {
                
                weak var destinationVC = segue.destination as? AboutTableViewController
                
                if segue.identifier == "phataToAboutSegue" {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is SocialLinksTableViewController {
                
                weak var destinationVC = segue.destination as? SocialLinksTableViewController
                
                if segue.identifier == "phataToSocialLinksSegue" {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is EmergencyContactTableViewController {
                
                weak var destinationVC = segue.destination as? EmergencyContactTableViewController
                
                if segue.identifier == "phataToEmergencyContactSegue" {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is PhataPictureViewController {
                
                weak var destinationVC = segue.destination as? PhataPictureViewController
                
                if segue.identifier == "phataToProfilePictureSegue" {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is PHATASettingsTableViewController {
                
                weak var destinationVC = segue.destination as? PHATASettingsTableViewController
                
                if segue.identifier == "phataSettingsSegue" {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is AddressTableViewController {
                
                weak var destinationVC = segue.destination as? AddressTableViewController
                
                if segue.identifier == "phataToAddressSegue" {
                    
                    destinationVC?.profile = self.profile
                }
            }
        }
    }

}
