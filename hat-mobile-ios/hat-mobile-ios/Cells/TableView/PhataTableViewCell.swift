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

import UIKit

// MARK: Class

/// A class responsible for handling the phata table view cell
class PhataTableViewCell: UITableViewCell, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Variables
    
    /// The options of the picker view
    var dataSourceForPickerView: [String] = ["", "Mr.", "Mrs.", "Miss", "Dr."]
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the switch
    @IBOutlet weak var privateSwitch: CustomSwitch!
    
    /// An IBOutlet for handling the textField
    @IBOutlet weak var textField: UITextField!
    
    /// An IBOutlet for handling the textView
    @IBOutlet weak var textView: UITextView!
    
    // MARK: - IBActions
    
    /**
     A function called everytime the value of the switch has changed
     
     - parameter sender: The object that called this function
     */
    @IBAction func valueDidChange(_ sender: Any) {
    }
    
    // MARK: - PickerView methods
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return dataSourceForPickerView.count
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if row >= self.dataSourceForPickerView.count - 1 {
            
            let selectedRow = self.getRowForItemInDataSource(item: self.textField.text)
            if pickerView.numberOfRows(inComponent: component) >= selectedRow {
                
                pickerView.selectRow(selectedRow, inComponent: component, animated: true)
            }
        }
        return dataSourceForPickerView[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.textField.text = self.dataSourceForPickerView[row]
    }
    
    // MARK: - TableViewCell methods
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.textView?.delegate = self
        self.textField?.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Picker did update date
    
    /**
     Updates the textField according to the selection of the datePicker
     
     - parameter datePicker: The datePicker that called this method
     */
    func datePickerDidUpdateDate(datePicker: UIDatePicker) {
        
        self.textField.text = FormatterHelper.formatDateStringToUsersDefinedDate(date: datePicker.date, dateStyle: .short, timeStyle: .none)
    }
    
    // MARK: - TextField delegate method

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField.tag == 15 || textField.tag == 10 || textField.tag == 11 {
            
            let pickerView = UIPickerView()
            pickerView.delegate = self
            pickerView.dataSource = self
            textField.inputView = pickerView
        } else if textField.tag == 12 {
            
            let datePickerView = UIDatePicker()
            datePickerView.addTarget(self, action: #selector(datePickerDidUpdateDate(datePicker:)), for: .valueChanged)

            datePickerView.locale = .current
            datePickerView.datePickerMode = .date
            textField.inputView = datePickerView
            let date = FormatterHelper.formatStringToDate(string: textField.text!)
            if date != nil {
                
                datePickerView.setDate(date!, animated: true)
            }
            textField.text = FormatterHelper.formatDateStringToUsersDefinedDate(date: datePickerView.date, dateStyle: .short, timeStyle: .none)
        } 
        
        return true
    }
    
    // MARK: - Find Row in picker view for this item
    
    /**
     Searches and returns the position of a string in the data source of the picker view
     
     - parameter item: The item we are looking for
     - returns: 0 if not found else the index of the string in the array
     */
    private func getRowForItemInDataSource(item: String?) -> Int {
        
        var isFound = false

        if item != nil {
            
            for (index, dataItem) in self.dataSourceForPickerView.enumerated() {
                
                if item!.lowercased() == dataItem.lowercased() {
                    
                    isFound = true
                    return index
                }
            }
        }
        
        if !isFound {
            
            return 0
        }
    }
}
