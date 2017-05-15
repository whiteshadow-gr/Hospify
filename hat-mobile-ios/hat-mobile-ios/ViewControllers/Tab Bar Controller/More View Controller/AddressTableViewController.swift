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

/// A class responsible for the address UITableViewController of the PHATA section
class AddressTableViewController: UITableViewController, UserCredentialsProtocol, UITextFieldDelegate {
    
    // MARK: - Variables
    
    /// The sections of the table view
    private let sections: [[String]] = [[""], [""], [""], ["Make those fields public?"]]
    /// The headers of the table view
    private let headers: [String] = ["City", "State / County", "Country", "Privacy"]
    /// The loading view pop up
    private var loadingView: UIView = UIView()
    /// A dark view covering the collection view cell
    private var darkView: UIView = UIView()
    
    /// User's profile passed on from previous view controller
    var profile: HATProfileObject? = nil
    
    // MARK: - IBActions

    /**
     Sends the profile data to hat
     
     - parameter sender: The object that calls this function
     */
    @IBAction func saveButtonAction(_ sender: Any) {
        
        self.tableView.endEditing(true)
        
        self.darkView = UIView(frame: self.tableView.frame)
        self.darkView.backgroundColor = .black
        self.darkView.alpha = 0.4
        
        self.view.addSubview(self.darkView)
        
        self.loadingView = UIView.createLoadingView(with: CGRect(x: (self.view?.frame.midX)! - 70, y: (self.view?.frame.midY)! - 15, width: 140, height: 30), color: .teal, cornerRadius: 15, in: self.view, with: "Updating profile...", textColor: .white, font: UIFont(name: "OpenSans", size: 12)!)
        
        for (index, _) in self.headers.enumerated() {
            
            var cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? PhataTableViewCell
            
            if cell == nil {
                
                let indexPath = IndexPath(row: 0, section: index)
                cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as? PhataTableViewCell
                cell = self.setUpCell(cell: cell!, indexPath: indexPath) as? PhataTableViewCell
            }
            
            // city
            if index == 0 {
                
                profile?.data.addressGlobal.city = cell!.textField.text!
            // state
            } else if index == 1 {
                
                profile?.data.addressGlobal.county = cell!.textField.text!
            // country
            }else if index == 2 {
                
                profile?.data.addressGlobal.country = cell!.textField.text!
            // is private
            } else if index == 3 {
                
                profile?.data.addressGlobal.isPrivate = !(cell!.privateSwitch.isOn)
                if (profile?.data.isPrivate)! && cell!.privateSwitch.isOn {
                    
                    profile?.data.isPrivate = false
                }
            }
        }
        
        func tableExists(dict: Dictionary<String, Any>, renewedUserToken: String?) {
            
            HATAccountService.postProfile(userDomain: userDomain, userToken: userToken, hatProfile: self.profile!, successCallBack: {
                
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
    
    // MARK: - View controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if self.profile == nil {
            
            self.profile = HATProfileObject()
        }
        
        self.tableView.addBackgroundTapRecogniser()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! PhataTableViewCell
        
        return self.setUpCell(cell: cell, indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.headers[section]
    }
    
    // MARK: - Set up cell
    
    /**
     Updates and formats the cell accordingly
     
     - parameter cell: The PhataTableViewCell to update and format
     - parameter indexPath: The indexPath of the cell
     
     - returns: A UITableViewCell cell already updated and formatted accordingly
     */
    private func setUpCell(cell: PhataTableViewCell, indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            cell.textField.text = self.profile?.data.addressGlobal.city
            cell.privateSwitch.isHidden = true
        } else if indexPath.section == 1 {
            
            cell.textField.text = self.profile?.data.addressGlobal.county
            cell.privateSwitch.isHidden = true
        } else if indexPath.section == 2 {
            
            cell.textField.text = self.profile?.data.addressGlobal.country
            cell.privateSwitch.isHidden = true
            cell.textField.delegate = self
            cell.textField.addTarget(self, action: #selector(textFieldValueChanged(textField:)), for: UIControlEvents.allEditingEvents)
        } else if indexPath.section == 3 {
            
            cell.textField.text = self.sections[indexPath.section][indexPath.row]
            cell.privateSwitch.isHidden = false
            cell.privateSwitch.isOn = !(self.profile?.data.addressGlobal.isPrivate)!
        }
        
        return cell
    }
    
    func textFieldValueChanged(textField: UITextField) {
        
        var text = textField.text!
        var cursorPosition: Int = 0
        
        if let selectedRange = textField.selectedTextRange {
            
            cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
            
            let index = text.index(text.startIndex, offsetBy: cursorPosition)
            text = text.substring(to: index)
        }
        
        let countries = self.getCountries()
        var found = false
        
        for country in countries where text.characters.count > 0 {
            
            if country.lowercased().hasPrefix(text.lowercased()) {
                
                let partOne = text.createTextAttributes(foregroundColor: .black, strokeColor: .black, font: UIFont(name: Constants.fontNames.openSans.rawValue, size: 14)!)
                
                let replacedText = country.lowercased().replacingOccurrences(of: text.lowercased(), with: "")
                let partTwo = replacedText.createTextAttributes(foregroundColor: .gray, strokeColor: .gray, font: UIFont(name: Constants.fontNames.openSans.rawValue, size: 14)!)
                textField.attributedText = partOne.combineWith(attributedText: partTwo)
                
                if let newPosition = textField.position(from: textField.beginningOfDocument, offset: cursorPosition) {
                    
                    textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                }
                
                found = true
                break
            }
        }
        
        if !found {
            
          textField.text = text
        }
        
        if text.characters.count < 1 {
            
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let stringToFind = textField.attributedText?.string
        
        let countries = self.getCountries()
        
        for i in 0...countries.count - 1 {
            
            if countries[i].lowercased() == stringToFind?.lowercased() {
                
                textField.text = countries[i]
                break
            }
        }
    }
    
    private func getCountries() -> [String] {
        
        let locale: NSLocale = NSLocale.current as NSLocale
        let countryArray = Locale.isoRegionCodes
        let unsortedCountryArray: [String] = countryArray.map { (countryCode) -> String in

            return locale.displayName(forKey: NSLocale.Key.countryCode, value: countryCode)!
        }

        return unsortedCountryArray.sorted()
    }

}
