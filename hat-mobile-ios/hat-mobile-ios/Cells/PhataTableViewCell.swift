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

class PhataTableViewCell: UITableViewCell, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var dataSourceForPickerView: [String] = ["", "Mr.", "Mrs.", "Miss", "Dr."]

    var isThisTitleTextField: Bool = false
    var isThisAgeTextField: Bool = false
    var isThisBirthTextField: Bool = false
    var isThisGenderTextField: Bool = false
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return dataSourceForPickerView.count
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return dataSourceForPickerView[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.textField.text = self.dataSourceForPickerView[row]
    }

    @IBOutlet weak var privateSwitch: CustomSwitch!
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func valueDidChange(_ sender: Any) {
        
        print(self.privateSwitch.isOn)
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.textField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
    
    func datePickerDidUpdateDate(datePicker: UIDatePicker) {
        
        self.textField.text = FormatterHelper.formatDateStringToUsersDefinedDate(date: datePicker.date, dateStyle: .short, timeStyle: .none)
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if isThisTitleTextField || isThisAgeTextField || isThisGenderTextField {
            
            let pickerView = UIPickerView()
            pickerView.delegate = self
            pickerView.dataSource = self
            textField.inputView = pickerView
        } else if isThisBirthTextField {
            
            let datePickerView = UIDatePicker()
            datePickerView.addTarget(self, action: #selector(datePickerDidUpdateDate(datePicker:)) , for: .valueChanged)
            datePickerView.locale = .current
            datePickerView.datePickerMode = .date
            textField.inputView = datePickerView
            textField.text = FormatterHelper.formatDateStringToUsersDefinedDate(date: datePickerView.date, dateStyle: .short, timeStyle: .none)
        } 
        
        return true
    }
}
