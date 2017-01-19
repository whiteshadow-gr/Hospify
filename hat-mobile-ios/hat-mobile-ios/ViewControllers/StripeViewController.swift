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
import Alamofire

// MARK: Class

/// The class responsible for buying stuff via Stripe
class StripeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Variables
    
    /// the SKU determining the product user wants to buy
    var sku: String = ""
    /// Stripe token for this purchase
    var token: String = ""
    
    /// The purchase model to work on and push to the hat later
    private var purchaseModel: PurchaseModel = PurchaseModel()
    /// An array with all the countries
    private let countriesArray: [String] = StripeViewController.getCountries()
    /// A picker view to show as inputView on keyboard later
    private let privatePicker = UIPickerView()
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the arrow bar on top of the view
    @IBOutlet weak var arrowBarImage: UIImageView!
    
    /// An IBOutlet for handling the first name textField
    @IBOutlet weak var firstNameTextField: UITextField!
    /// An IBOutlet for handling the last name textField
    @IBOutlet weak var lastNameTextField: UITextField!
    /// An IBOutlet for handling the nickname textField
    @IBOutlet weak var nicknameTextField: UITextField!
    /// An IBOutlet for handling the email textField
    @IBOutlet weak var emailTextField: UITextField!
    /// An IBOutlet for handling the personal HAT address textField
    @IBOutlet weak var personalHATAddressTextField: UITextField!
    /// An IBOutlet for handling the password textField
    @IBOutlet weak var passwordTextField: UITextField!
    /// An IBOutlet for handling the invitation code textField
    @IBOutlet weak var invitationCodeTextField: UITextField!
    /// An IBOutlet for handling the country textField
    @IBOutlet weak var countryTextField: UITextField!
    
    /// An IBOutlet for handling the terms and conditions button
    @IBOutlet weak var termsAndConditionsButton: UIButton!
    
    /// An IBOutlet for handling the data view
    @IBOutlet weak var dataView: UIView!
    
    /// An IBOutlet for handling the scrollView
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - IBActions
    
    /**
     <#Function Details#>
     
     - parameter sender: The object called this method
     */
    @IBAction func termsAndConditionsButtonAction(_ sender: Any) {
    }
    
    /**
     Creates a hat
     
     - parameter sender: The object called this method
     */
    @IBAction func createHATButtonAction(_ sender: Any) {
        
        // configure the purchaseModel basen on the info entered
        purchaseModel.address = self.personalHATAddressTextField.text!
        purchaseModel.country = self.countryTextField.text!
        purchaseModel.email = self.emailTextField.text!
        purchaseModel.firstName = self.firstNameTextField.text!
        purchaseModel.lastName = self.lastNameTextField.text!
        purchaseModel.nick = self.nicknameTextField.text!
        purchaseModel.password = self.passwordTextField.text!
        
        purchaseModel.sku = self.sku
        purchaseModel.token = self.token
        purchaseModel.termsAgreed = true
        
        // create the json file based on the purchaseModel
        let json = JSONHelper.createPurchaseJSONFrom(purchaseModel: purchaseModel)
        
        // url to make the request
        let url = "https://hatters.hubofallthings.com/api/products/hat/purchase"
        
        // request the creation of the hat
        let _ = Alamofire.request(url, method: .post, parameters: json, encoding: Alamofire.JSONEncoding.default, headers: nil).responseJSON(completionHandler: { response in
        
            print(response)
        })
    }
    
    // MARK: - View controller methods

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // config the arrowBar
        arrowBarImage.image = arrowBarImage.image!.withRenderingMode(.alwaysTemplate)
        arrowBarImage.tintColor = UIColor.rumpelVeryLightGray()
        
        // add border to terms and conditions button
        self.termsAndConditionsButton.addBorderToButton(width: 1, color: .lightGray)
        
        // configure the pickerView
        self.privatePicker.dataSource = self
        self.privatePicker.delegate = self
        
        // add the pickerView as an inputView to the textField
        self.countryTextField.inputView = self.privatePicker
        
        // create 2 notification observers for listening to the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHandling(sender:)), name:.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHandling(sender:)), name:.UIKeyboardWillHide, object: nil);
        
        // add handling for taps
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Get Countries
    
    /**
     Creates and returns an array with all the countries
     
     - returns: An array of String
     */
    class func getCountries() -> [String] {
        
        let locale: NSLocale = NSLocale.current as NSLocale
        let countryArray = Locale.isoRegionCodes
        let unsortedCountryArray: [String] = countryArray.map { (countryCode) -> String in
            
            return locale.displayName(forKey: NSLocale.Key.countryCode, value: countryCode)!
        }
        
        return unsortedCountryArray.sorted()
    }
    
    // MARK: - UIPickerView methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return countriesArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return countriesArray[row] as String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.countryTextField.text = self.countriesArray[row]
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
