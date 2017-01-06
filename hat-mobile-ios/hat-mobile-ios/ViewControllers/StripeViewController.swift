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
import Stripe
import Alamofire

// MARK: Class

/// The class responsible for buying staff via Stripe
class StripeViewController: UIViewController {
    
    // MARK: - Variables
    
    var sku: String = ""
    private var stripeModel = StripeModel()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var hatProviderImage: UIImageView!
    
    @IBOutlet weak var hatProviderTitleLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var postCodeTextField: UITextField!
    @IBOutlet weak var coyntryTextField: UITextField!
    @IBOutlet weak var cardTextField: UITextField!
    @IBOutlet weak var cardExpiryTextField: UITextField!
    @IBOutlet weak var cardCVVTextField: UITextField!
    
    // MARK: - IBActions
    
    @IBAction func subscribeButtonAction(_ sender: Any) {
        
        // Initiate the card
        let stripCard = STPCardParams()
        
        // Split the expiration date to extract Month & Year
        if self.cardExpiryTextField.text?.isEmpty == false {
            
            let expirationDate = self.cardExpiryTextField.text?.components(separatedBy: "/")
            let expMonth = UInt((expirationDate?[0])!)
            let expYear = UInt((expirationDate?[1])!)
            
            // Send the card info to Strip to get the token
            stripCard.number = self.cardTextField.text
            stripCard.cvc = self.cardCVVTextField.text
            stripCard.expMonth = expMonth!
            stripCard.expYear = expYear!
            
            let address = STPAddress()
            
            address.city = self.cityTextField.text
            address.line1 = self.addressTextField.text
            address.country = self.coyntryTextField.text
            address.postalCode = self.postCodeTextField.text
            
            stripCard.address = address
            stripCard.name = self.nameTextField.text
            
            stripeModel.address = address.line1!
            stripeModel.city = address.city!
            stripeModel.postCode = address.postalCode!
            stripeModel.country = address.country!
            //stripeModel.state = address.state!
            
            stripeModel.cardCVV = stripCard.cvc!
            stripeModel.cardNumber = stripCard.number!
            stripeModel.cardExpiryMonth = String(stripCard.expYear)
            stripeModel.cardExpiryYear = String(stripCard.expMonth)
            
            stripeModel.name = stripCard.name!
            stripeModel.email = self.emailTextField.text!
            stripeModel.sku = self.sku
        }
        
        if STPCardValidator.validationState(forCard: stripCard) == .valid {
            
            STPAPIClient.shared().createToken(withCard: stripCard, completion: { (token, error) -> Void in
                
                if error != nil {
                    
                    self.handleError(error: error!)
                    return
                }
                
                self.stripeModel.token = (token?.tokenId)!
                self.postStripeToken()
            })
        } else {
            
            self.createClassicOKAlertWith(alertMessage: "No card", alertTitle: "Please Try Again", okTitle: "OK", proceedCompletion: {() -> Void in return})
        }
    }
    
    func handleError(error: Error) {
        
        print(error)
        self.createClassicOKAlertWith(alertMessage: error.localizedDescription, alertTitle: "Please Try Again", okTitle: "OK", proceedCompletion: {() -> Void in return})
    }
    
    func postStripeToken() {
        
        let json = JSONHelper.createPurchaseJSONFrom(stripeModel: stripeModel)
        let url = "https://hatters.hubofallthings.com/api/products/hat/purchase"
        
        Alamofire.request(url, method: .post, parameters: json, encoding: Alamofire.JSONEncoding.default, headers: [:]).responseJSON(completionHandler: {(data: DataResponse<Any>) -> Void in
        
            print(data)
        })
    }
    
    // MARK: - View controller methods

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
