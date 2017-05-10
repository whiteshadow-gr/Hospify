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

import MapKit

// MARK: Class

/// The settings view controller
class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    // MARK: - Variables

    /// A MapSettingsDelegate object to pass back to the location tabs the stored values
    var mapSettingsDelegate: MapSettingsDelegate? = nil

    /// The UIPicker data. initialiser code below needs to change if you re-order this array
    private let pickerAccuracyData = ["kCLLocationAccuracyHundredMeters", "kCLLocationAccuracyKilometer", "kCLLocationAccuracyThreeKilometers", "kCLLocationAccuracyNearestTenMeters"]
    
    // MARK: - IBOutlets
  
    /// An IBOutlet for handling the UIPickerView
    @IBOutlet weak var pickerAccuracy: UIPickerView!
    
    /// An IBOutlet for handling the distance UITextField
    @IBOutlet weak var textFieldDistance: UITextField!
    /// An IBOutlet for handling the deferred time UITextField
    @IBOutlet weak var textFieldDeferredTime: UITextField!
    /// An IBOutlet for handling the deferred distance UITextField
    @IBOutlet weak var textFieldDeferredDistance: UITextField!
    
    /// An IBOutlet for handling the location UISwitch
    @IBOutlet weak var locationSwitchOutlet: UISwitch!
    
    /// An IBOutlet for handling the location tracking UILabel
    @IBOutlet weak var locationTrackingLabel: UILabel!
    
    //MARK: - IBActions 
    
    /**
     This method is called with the switch changes state
     
     - parameter sender: The object that called this method
     */
    @IBAction func locationSwitch(_ sender: Any) {
        
        if self.locationSwitchOutlet.isOn {
            
            _ = KeychainHelper.SetKeychainValue(key: "trackDevice", value: "true")
            self.locationTrackingLabel.text = "Location upload to HAT enabled"
        } else {
            
            _ = KeychainHelper.SetKeychainValue(key: "trackDevice", value: "false")
            self.locationTrackingLabel.text = "Location upload to HAT disabled"
        }
    }
    
    // MARK: - Auto generated methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // change view controller title
        self.title = NSLocalizedString("settings_label", comment: "settings title")
        
        if let result = KeychainHelper.GetKeychainValue(key: "trackDevice") {
            
            if result == "true" {
                
                self.locationSwitchOutlet.isOn = true
                self.locationTrackingLabel.text = "location upload to HAT enabled"
            } else {
                
                self.locationSwitchOutlet.isOn = false
                self.locationTrackingLabel.text = "location upload to HAT disabled"
            }
        } else {
            
            _ = KeychainHelper.SetKeychainValue(key: "trackDevice", value: "true")
            self.locationSwitchOutlet.isOn = true
            self.locationTrackingLabel.text = "location upload to HAT enabled"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // add notification observer
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillDisappear(notification:)),
                                               name:Notification.Name.UIKeyboardDidHide, object:nil)
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Notifications

    /**
     A notification based function, executed when keyboard hides
     
     - parameter notification: The notification object that called this method
     */
    @objc func keyboardWillDisappear(notification: NSNotification) {
        
        // Do something here
        self.storeValues()
    }

    //MARK: - UIPickerView delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return self.pickerAccuracyData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return self.pickerAccuracyData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       
        let valueSelected: String = self.pickerAccuracyData[row]
        var locationAccuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters //default
        
        switch valueSelected {
            
        case "kCLLocationAccuracyKilometer":
            
            locationAccuracy = kCLLocationAccuracyKilometer
        case "kCLLocationAccuracyHundredMeters":
            
            locationAccuracy = kCLLocationAccuracyHundredMeters
        case "kCLLocationAccuracyNearestTenMeters":
            
            locationAccuracy = kCLLocationAccuracyNearestTenMeters
        case "kCLLocationAccuracyThreeKilometers":
            
            locationAccuracy = kCLLocationAccuracyThreeKilometers
        default:
            
            locationAccuracy = kCLLocationAccuracyHundredMeters
        }
        
        UserDefaults.standard.set(locationAccuracy, forKey: Constants.Preferences.MapLocationAccuracy)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        var titleData: String = self.pickerAccuracyData[row]
        let valueSelected: String = self.pickerAccuracyData[row]
        
        switch valueSelected {
            
        case "kCLLocationAccuracyKilometer":
            
            titleData = NSLocalizedString("location_kCLLocationAccuracyKilometer", comment: "")
        case "kCLLocationAccuracyHundredMeters":
            
            titleData = NSLocalizedString("location_kCLLocationAccuracyHundredMeters", comment: "")
        case "kCLLocationAccuracyNearestTenMeters":
            
            titleData = NSLocalizedString("location_kCLLocationAccuracyNearestTenMeters", comment: "")
        case "kCLLocationAccuracyThreeKilometers":
            
            titleData = NSLocalizedString("location_kCLLocationAccuracyThreeKilometers", comment: "")
        default:
            
            titleData = NSLocalizedString("location_kCLLocationAccuracyNearestTenMeters", comment: "")
        }
        
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "OpenSans", size: 13.0)!,NSForegroundColorAttributeName:UIColor.black])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .center
        
        return pickerLabel
    }
    
    // MARK: - Navigation
    
    override func willMove(toParentViewController parent: UIViewController?) {
        
        super.willMove(toParentViewController: parent)
        
        if parent == nil {
            
            // the back button was pressed.
            if (self.mapSettingsDelegate != nil) {
                
                storeValues()
            }
        }
    }
    
    // MARK: - UItextField delegate
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Set and get values
    
    /**
     Stores values to user defaults
     */
    private func storeValues() {
        
        // pass new settings back and read the defaults from user defaults
        self.mapSettingsDelegate?.onChanged()
        //readAndDisplayCurrentDefaults()
    }
    
    /**
     Gets the values from user defaults
     */
    private func readAndDisplayCurrentDefaults() {
        
        // get settings from user defaults
        self.textFieldDistance.text = String(MapsHelper.GetUserPreferencesDistance())
        self.textFieldDistance.setNeedsDisplay()
        
        self.textFieldDeferredDistance.text = String(MapsHelper.GetUserPreferencesDeferredDistance())
        self.textFieldDeferredDistance.setNeedsDisplay()
        
        self.textFieldDeferredTime.text = String(MapsHelper.GetUserPreferencesDeferredTimeout())
        self.textFieldDeferredTime.setNeedsDisplay()
    }
    
    // MARK: - UIPickerView select row 
    
    /**
     Selects row in the UIPickerView from settings in user defaults
     
     - parameter picker: The UIPickerView to select the row
     - parameter animated: Animated selection or not
     */
    private func selectRowInPickerViewFromUserDefaults(picker: UIPickerView, animated: Bool) {
        
        switch MapsHelper.GetUserPreferencesAccuracy() {
            
        case kCLLocationAccuracyKilometer:
            
            picker.selectRow(1, inComponent: 0, animated: animated)
        case kCLLocationAccuracyHundredMeters:
            
            picker.selectRow(0, inComponent: 0, animated: animated)
        case kCLLocationAccuracyNearestTenMeters:
            
            picker.selectRow(3, inComponent: 0, animated: animated)
        case kCLLocationAccuracyThreeKilometers:
            
            picker.selectRow(2, inComponent: 0, animated: animated)
        default:
            
            picker.selectRow(1, inComponent: 0, animated: animated)
        }
    }
}
