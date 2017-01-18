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

class ProfileViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Variables
    
    private let titleArray: [String] = ["Mr.", "Mrs.", "Miss", "Dr.", "Sir"]
    private let countriesArray: [String] = StripeViewController.getCountries()
    
    private let titlePickerView = UIPickerView()
    private let countriesPickerView = UIPickerView()
    
    private var learnMoreViewController = LearnMorePHATAViewController()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var phataSwitch: CustomSwitch!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var titleSwitch: CustomSwitch!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var firstNameSwitch: CustomSwitch!
    
    @IBOutlet weak var middleNameTextField: UITextField!
    @IBOutlet weak var middleNameSwitch: CustomSwitch!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var lastNameSwitch: CustomSwitch!
    
    @IBOutlet weak var preferedNameTextField: UITextField!
    @IBOutlet weak var preferedSwitch: CustomSwitch!
    
    @IBOutlet weak var primaryEmailTextField: UITextField!
    @IBOutlet weak var primaryEmailSwitch: CustomSwitch!
    
    @IBOutlet weak var alternativeEmailTextField: UITextField!
    @IBOutlet weak var alternativeEmailSwitch: CustomSwitch!
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var phoneNumberSwitch: CustomSwitch!
    
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var mobileNumberSwitch: CustomSwitch!
    
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var nicknameSwitch: CustomSwitch!
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var citySwitch: CustomSwitch!
    
    @IBOutlet weak var countyTextField: UITextField!
    @IBOutlet weak var countySwitch: CustomSwitch!
    
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var countrySwitch: CustomSwitch!
    
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var genderSwitch: CustomSwitch!
    
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var dataOfBirthSwitch: CustomSwitch!
    
    @IBOutlet weak var ageGroupTextField: UITextField!
    @IBOutlet weak var ageGroupSwitch: CustomSwitch!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - IBActions
    
    @IBAction func learnMoreButtonAction(_ sender: Any) {
        
        // create page view controller
        self.learnMoreViewController = self.storyboard!.instantiateViewController(withIdentifier: "learnMorePHATA") as! LearnMorePHATAViewController
        
        // set up the created page view controller
        self.learnMoreViewController.view.frame = CGRect(x: self.view.frame.origin.x + 15, y: self.view.frame.origin.x + 15, width: self.view.frame.width - 30, height: self.view.frame.height - 30)
        self.learnMoreViewController.view.layer.cornerRadius = 15
        
        // add the page view controller to self
        self.addChildViewController(learnMoreViewController)
        self.view.addSubview(learnMoreViewController.view)
        learnMoreViewController.didMove(toParentViewController: self)
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - View method methods

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // create 2 notification observers for listening to the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHandling(sender:)), name:.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHandling(sender:)), name:.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideLearnMore(sender:)), name:NSNotification.Name(rawValue: "HideLearnMore"), object: nil)
        
        titlePickerView.tag = 1
        titlePickerView.delegate = self
        titlePickerView.dataSource = self
        
        countriesPickerView.tag = 2
        countriesPickerView.delegate = self
        countriesPickerView.dataSource = self
        
        self.titleTextField.inputView = self.titlePickerView
        self.countryTextField.inputView = self.countriesPickerView
    }
    
    func hideLearnMore(sender: Notification) {
        
        learnMoreViewController.willMove(toParentViewController: nil)
        learnMoreViewController.view.removeFromSuperview()
        learnMoreViewController.removeFromParentViewController()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIPickerView methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == 1 {
            
            return titleArray.count
        }
        
        return countriesArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 1 {
            
            return titleArray[row] as String
        }
        
        return countriesArray[row] as String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 1 {
            
            self.titleTextField.text = self.titleArray[row]
        } else {
            
            self.countryTextField.text = self.countriesArray[row]
        }
    }
    
    // MARK: - Keyboard handling
    
    /**
     Function executed before the keyboard is shown to the user
     
     - parameter sender: The object that called this method
     */
    func keyboardHandling(sender: NSNotification) {
        
        let userInfo = sender.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if sender.name == Notification.Name.UIKeyboardWillHide {
            
            self.scrollView.contentInset = UIEdgeInsets.zero
        } else {
            
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height + 60, right: 0)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
