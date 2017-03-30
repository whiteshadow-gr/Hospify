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

import SafariServices
import MessageUI
import HatForIOS

// MARK: Class

/// The Login View Controller
class LoginViewController: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    // MARK: - IBOutlets

    /// An IBOutlet for handling the learnMoreButton
    @IBOutlet weak var learnMoreButton: UIButton!
    /// An IBOutlet for handling the getAHATButton
    @IBOutlet weak var getAHATButton: UIButton!
    /// An IBOutlet for handling the buttonLogon
    @IBOutlet weak var buttonLogon: UIButton!
    /// An IBOutlet for handling the joinCommunityButton
    @IBOutlet weak var joinCommunityButton: UIButton!
    /// An IBOutlet for handling the domainButton
    @IBOutlet weak var domainButton: UIButton!
    
    /// An IBOutlet for handling the inputUserHATDomain
    @IBOutlet weak var inputUserHATDomain: UITextField!
    
    /// An IBOutlet for handling the labelAppVersion
    @IBOutlet weak var labelAppVersion: UILabel!
    
    /// An IBOutlet for handling the labelTitle
    @IBOutlet weak var labelTitle: UITextView!
    /// An IBOutlet for handling the labelSubTitle
    @IBOutlet weak var labelSubTitle: UITextView!
    
    @IBOutlet weak var testImage: UIImageView!
    /// An IBOutlet for handling the ivLogo
    @IBOutlet weak var ivLogo: UIImageView!
    
    /// An IBOutlet for handling the scrollView
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Variables
    
    /// A String typealias
    typealias MarketAccessToken = String
   
    /// SafariViewController variable
    private var safariVC: SFSafariViewController?
    
    /// SafariViewController variable
    private var popUpView: UIView?
        
    // MARK: - IBActions
    
    /**
     A button showing the different HAT's to select in order to log in
     
     - parameter sender: The object that called this method
     */
    @IBAction func domainButtonAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "Select domain", message: nil, preferredStyle: .actionSheet)
        
        let hubofallthingsAction = UIAlertAction(title: ".hubofallthings.net", style: .default, handler: {(alert: UIAlertAction) -> Void in
            
            self.domainButton.setTitle(".hubofallthings.net", for: .normal)
        })
        
        let bsafeAction = UIAlertAction(title: ".bsafe.org", style: .default, handler: {(alert: UIAlertAction) -> Void in
            
            self.domainButton.setTitle(".bsafe.org", for: .normal)
        })
        
        let hubatAction = UIAlertAction(title: ".hubat.net", style: .default, handler: {(alert: UIAlertAction) -> Void in
            
            self.domainButton.setTitle(".hubat.net", for: .normal)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(hubofallthingsAction)
        alert.addAction(bsafeAction)
        alert.addAction(hubatAction)
        alert.addAction(cancelAction)
        
        // if user is on ipad show as a pop up
        if UI_USER_INTERFACE_IDIOM() == .pad {
            
            alert.popoverPresentationController?.sourceRect = self.domainButton.frame
            alert.popoverPresentationController?.sourceView = self.domainButton
        }
        
        // present alert controller
        self.navigationController!.present(alert, animated: true, completion: nil)
    }
    
    /**
     A button launching email view controller
     
     - parameter sender: The object that called this method
     */
    @IBAction func contactUsActionButton(_ sender: Any) {
        
        if MFMailComposeViewController.canSendMail() {
            
            // create mail view controler
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = self
            mailVC.setToRecipients(["contact@hatdex.org"])
            
            // present view controller
            self.present(mailVC, animated: true, completion: nil)
        } else {
            
            self.createClassicOKAlertWith(alertMessage: "This device has not been configured to send emails", alertTitle: "Email services disabled", okTitle: "ok", proceedCompletion: {})
        }
    }
    
    /**
     A button opening safari to redirect user to mad hatters
     
     - parameter sender: The object that called this method
     */
    @IBAction func joinOurCommunityButtonAction(_ sender: Any) {
        
        let urlStr = "http://hubofallthings.com/main/the-mad-hatters/"
        if let url = URL(string: urlStr) {
            
            UIApplication.shared.openURL(url)
        }
    }
    
    /**
     An action executed when the logon button is pressed
     
     - parameter sender: The object that calls this method
     */
    @IBAction func buttonLogonTouchUp(_ sender: AnyObject) {
        
        func failed(error: String) {
            
            self.createClassicOKAlertWith(alertMessage: "Please check your personal hat address again", alertTitle: "Wrong domain!", okTitle: "OK", proceedCompletion: {() -> Void in return})
        }
        
        if self.inputUserHATDomain.text != "" {
            
            _ = KeychainHelper.SetKeychainValue(key: "logedIn", value: "false")
            let filteredDomain = self.removeDomainFromUserEnteredText(domain: self.inputUserHATDomain.text!)

            HATLoginService.logOnToHAT(userHATDomain: filteredDomain + (self.domainButton.titleLabel?.text)!, successfulVerification: self.authoriseUser, failedVerification: failed)
        } else {
            
            self.createClassicOKAlertWith(alertMessage: "Please input your HAT domain", alertTitle: "HAT domain is empty!", okTitle: "Ok", proceedCompletion: {})
        }
    }
    
    // MARK: - Remove domain from entered text
    
    /**
     Removes domain from entered text
     
     - parameter domain: The user entered text
     - returns: The filtered text
     */
    private func removeDomainFromUserEnteredText(domain: String) -> String {
        
        let array = domain.components(separatedBy: ".")
        
        if array.count > 0 {
            
            return array[0]
        }
        
        return domain
    }
    
    // MARK: - View Controller functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // add keyboard handling
        self.addKeyboardHandling()
        self.hideKeyboardWhenTappedAround()
        
        // disable the navigation back button
        self.navigationItem.setHidesBackButton(true, animated:false)
        
        // set title
        self.title = NSLocalizedString("logon_label", comment:  "logon title")
        
        let partOne = "Rumpel ".createTextAttributes(foregroundColor: .white, strokeColor: .white, font: UIFont(name: Constants.fontNames.openSansCondensedLight.rawValue, size: 36)!)
        let partTwo = "Lite".createTextAttributes(foregroundColor: .tealColor(), strokeColor: .tealColor(), font: UIFont(name: Constants.fontNames.openSansCondensedLight.rawValue, size: 36)!)
        
        self.labelTitle.attributedText = partOne.combineWith(attributedText: partTwo)
        self.labelTitle.textAlignment = .center
        
        // move placeholder inside by 5 points
        self.inputUserHATDomain.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        
        // input
        self.inputUserHATDomain.placeholder = NSLocalizedString("hat_domain_placeholder", comment:  "user HAT domain")

        // button
        self.buttonLogon.setTitle(NSLocalizedString("logon_label", comment:  "username"), for: UIControlState())
        self.buttonLogon.backgroundColor = Constants.Colours.AppBase
        
        // app version
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            
            self.labelAppVersion.text = "v. " + version
        }
        
        // add notification observer for the login in
        NotificationCenter.default.addObserver(self, selector: #selector(self.hatLoginAuth), name: NSNotification.Name(rawValue: Constants.Auth.NotificationHandlerName), object: nil)
        
        self.joinCommunityButton.addBorderToButton(width: 1, color: .white)
        self.getAHATButton.addBorderToButton(width: 1, color: .white)
        self.learnMoreButton.addBorderToButton(width: 1, color: .white)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // when the view appears clear the text field. The user might pressed sing out, this field must not contain the previous address
        self.inputUserHATDomain.text = ""
        
        // Create a button bar for the number pad
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 35)
        
        if let result = KeychainHelper.GetKeychainValue(key: Constants.Keychain.HATDomainKey) {
            
            let barButtonTitle = result
            
            // Setup the buttons to be put in the system.
            let autofillButton = UIBarButtonItem(title: barButtonTitle, style: .done, target: self, action: #selector(self.autofillPHATA))
            autofillButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: Constants.fontNames.openSans.rawValue, size: 16.0)!, NSForegroundColorAttributeName: UIColor.white], for: .normal)
            toolbar.barTintColor = .black
            toolbar.setItems([autofillButton], animated: true)
            
            if barButtonTitle != "" {
                
                self.inputUserHATDomain.inputAccessoryView = toolbar
                self.inputUserHATDomain.inputAccessoryView?.backgroundColor = .black
            }
        }
    }
    
    // MARK: - Mail View controller
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Accesory Input View Method
    
    /**
     Fills the domain text field with the user's domain
     */
    @objc private func autofillPHATA() {
        
        if let result = KeychainHelper.GetKeychainValue(key: Constants.Keychain.HATDomainKey) {
            
            let domain = result.components(separatedBy: ".")
            self.inputUserHATDomain.text = domain[0]
            self.domainButton.setTitle("." + domain[1] + "." + domain[2], for: .normal)
        }
    }
    
    // MARK: - Authorisation functions
    
    /**
     Authorise user with the hat
     
     - parameter hatDomain: The phata address of the user
     */
    private func authoriseUser(hatDomain: String) {
        
        // build up the hat domain auth url
        let hatDomainURL = "https://" + hatDomain + "/hatlogin?name=" + Constants.Auth.ServiceName + "&redirect=" +
            Constants.Auth.URLScheme + "://" + Constants.Auth.LocalAuthHost
              
        self.safariVC = SFSafariViewController.openInSafari(url: hatDomainURL, on: self, animated: true, completion: nil)
    }
    
    /**
     The notification received from the login precedure.
     
     - parameter NSNotification: notification
     */
    @objc private func hatLoginAuth(notification: NSNotification) {
        
        // get the url form the auth callback
        let url = notification.object as! NSURL
        
        // first of all, we close the safari vc
        self.safariVC?.dismissSafari(animated: true, completion: nil)
        
        self.popUpView = UIView()
        popUpView!.createFloatingView(frame: CGRect(x: self.view.frame.midX - 60, y: self.view.frame.midY - 15, width: 120, height: 30), color: .tealColor(), cornerRadius: 15)
        
        let label = UILabel().createLabel(frame: CGRect(x: 0, y: 0, width: 120, height: 30), text: "Authenticating...", textColor: .white, textAlignment: .center, font: UIFont(name: "OpenSans", size: 12))
        
        self.popUpView!.addSubview(label)
        
        self.view.addSubview(self.popUpView!)
        
        func success(token: String?) {
            
            self.hidePopUpLabel()
            
            if token != "" || token != nil {
                
                _ = KeychainHelper.SetKeychainValue(key: "UserToken", value: token!)
            }
            
            let userDomain = HATAccountService.TheUserHATDomain()
            
            self.enableLocationDataPlug(userDomain, userDomain)
            _ = self.navigationController?.popToRootViewController(animated: false)
        }
        
        func failed(error: AuthenicationError) {
            
            self.hidePopUpLabel()
            
            switch error {
            case .cannotSplitToken(_):
                
                // no token in url callback redirect
                self.createClassicOKAlertWith(alertMessage: "Token error!", alertTitle: "Cannot split token", okTitle: "OK", proceedCompletion: {})
            case .cannotDecodeToken(_):
                
                // no token in url callback redirect
                self.createClassicOKAlertWith(alertMessage: "Token error!", alertTitle: "Cannot decode token", okTitle: "OK", proceedCompletion: {})
            case .generalError(_, let statusCode, let error):
                
                let msg: String = NetworkHelper.ExceptionFriendlyMessage(statusCode, defaultMessage: error!.localizedDescription)
                self.createClassicOKAlertWith(alertMessage: msg, alertTitle: NSLocalizedString("error_label", comment: "error"), okTitle: "OK", proceedCompletion: {})
            case .noIssuerDetectedError(_):
                
                // no token in url callback redirect
                self.createClassicOKAlertWith(alertMessage: "Token error!", alertTitle: "Cannot detect issuer", okTitle: "OK", proceedCompletion: {})
            case .noTokenDetectedError:
                
                // no token in url callback redirect
                self.createClassicOKAlertWith(alertMessage: NSLocalizedString("auth_error_no_token_in_callback", comment: "auth"), alertTitle: NSLocalizedString("error_label", comment: "error"), okTitle: "OK", proceedCompletion: {})
            case .tokenValidationFailed(_):
                
                self.createClassicOKAlertWith(alertMessage: NSLocalizedString("auth_error_invalid_token", comment: "auth"), alertTitle: NSLocalizedString("error_label", comment: "error"), okTitle: "OK", proceedCompletion: {})
            }
        }
        
        // authorize with hat
        let filteredDomain = self.removeDomainFromUserEnteredText(domain: self.inputUserHATDomain.text!)
        _ = KeychainHelper.SetKeychainValue(key: Constants.Keychain.HATDomainKey, value: self.inputUserHATDomain.text! + (self.domainButton.titleLabel?.text)!)
        HATLoginService.loginToHATAuthorization(userDomain: filteredDomain + (self.domainButton.titleLabel?.text)!, url: url, success: success, failed: failed)
    }
    
    /**
     Saves the hatdomain from token to keychain for easy log in
     
     - parameter userDomain: The user's domain
     - parameter HATDomainFromToken: The HAT domain extracted from the token
     */
    func enableLocationDataPlug(_ userDomain: String,_ HATDomainFromToken: String) {
        
        func success(result: Bool){
            
            // setting image to nil and everything to clear color because animation was laggy
            self.testImage.image = nil
            self.testImage.backgroundColor = .clear
            self.scrollView.backgroundColor = .clear
            self.view.backgroundColor = .clear
            self.hidePopUpLabel()
            
            _ = self.navigationController?.popToRootViewController(animated: false)
        }
        
        func failed(error: JSONParsingError) {
            
            switch error {
                
            case .expectedFieldNotFound:
                
                self.hidePopUpLabel()
                self.createClassicOKAlertWith(alertMessage: "Value not found", alertTitle: NSLocalizedString("error_label", comment: "error"), okTitle: "OK", proceedCompletion: {})
            case .generalError(_, _, _):
                
                self.hidePopUpLabel()
                self.createClassicOKAlertWith(alertMessage: NSLocalizedString("auth_error_keychain_save", comment: "keychain"), alertTitle: NSLocalizedString("error_label", comment: "error"), okTitle: "OK", proceedCompletion: {})
            }
        }
        
        HATLocationService.enableLocationDataPlug(userDomain, HATDomainFromToken, success: success, failed: failed)
    }
    
    // MARK: - Keyboard handling
    
    override func keyboardWillHide(sender: NSNotification) {
        
        self.hideKeyboardInScrollView(self.scrollView)
    }
    
    override func keyboardWillShow(sender: NSNotification) {
        
        self.showKeyboardInView(self.view, scrollView: self.scrollView, sender: sender)
    }
    
    // MARK: - Hide label 
    
    /**
     Hides the pop up, Authenticating..., label
     */
    func hidePopUpLabel() {
        
        self.popUpView?.removeFromSuperview()
    }
}
