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

/// The class responsible for buying staff via Stripe
class StripeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Variables
    
    var sku: String = ""
    var token: String = ""
    
    private var purchaseModel: PurchaseModel = PurchaseModel()
    private let countriesArray: [String] = StripeViewController.getCountries()
    private let privatePicker = UIPickerView()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var arrowBarImage: UIImageView!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var personalHATAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var invitationCodeTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    
    @IBOutlet weak var termsAndConditionsButton: UIButton!
    
    @IBOutlet weak var dataView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - IBActions
    
    /**
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     */
    @IBAction func termsAndConditionsButtonAction(_ sender: Any) {
    }
    
    /**
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     */
    @IBAction func createHATButtonAction(_ sender: Any) {
        
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
        
        let json = JSONHelper.createPurchaseJSONFrom(purchaseModel: purchaseModel)
        
        let url = "https://hatters.hubofallthings.com/api/products/hat/purchase"
        
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
        
        self.termsAndConditionsButton.addBorderToButton(width: 1, color: .lightGray)
        
        self.privatePicker.dataSource = self
        self.privatePicker.delegate = self
        
        self.countryTextField.inputView = self.privatePicker
        
        // create 2 notification observers for listening to the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHandling(sender:)), name:.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHandling(sender:)), name:.UIKeyboardWillHide, object: nil);
        
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Get Countries
    
    /**
     <#Function Details#>
     
     - returns: <#Returns#>
     */
    class func getCountries() -> [String] {
        
        let locale = Locale.current
        let countryArray = NSLocale.isoCountryCodes
        let unsortedCountryArray:[String] = countryArray.map { (countryCode) -> String in
            
            return (locale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: countryCode)!
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
