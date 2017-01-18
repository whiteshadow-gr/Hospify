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
import SafariServices

// MARK: - Class

/// The Login View Controller
class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the useWithoutHATButton
    @IBOutlet weak var useWithoutHATButton: UIButton!
    /// An IBOutlet for handling the learnMoreButton
    @IBOutlet weak var learnMoreButton: UIButton!
    /// An IBOutlet for handling the getAHATButton
    @IBOutlet weak var getAHATButton: UIButton!
    /// An IBOutlet for handling the buttonLogon
    @IBOutlet weak var buttonLogon: UIButton!
    
    /// An IBOutlet for handling the inputUserHATDomain
    @IBOutlet weak var inputUserHATDomain: UITextField!
    
    /// An IBOutlet for handling the labelAppVersion
    @IBOutlet weak var labelAppVersion: UILabel!
    
    /// An IBOutlet for handling the labelTitle
    @IBOutlet weak var labelTitle: UITextView!
    /// An IBOutlet for handling the labelSubTitle
    @IBOutlet weak var labelSubTitle: UITextView!
    
    /// An IBOutlet for handling the ivLogo
    @IBOutlet weak var ivLogo: UIImageView!
    
    /// An IBOutlet for handling the scrollView
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Variables
    
    /// A String typealias
    typealias MarketAccessToken = String
   
    /// SafariViewController variable
    private var safariVC: SFSafariViewController?
    
    // MARK: - IBActions
    
    /**
     An action executed when the logon button is pressed
     
     - parameter sender: The object that calls this method
     */
    @IBAction func buttonLogonTouchUp(_ sender: AnyObject) {
        
        let failed = {
            
            self.createClassicOKAlertWith(alertMessage: "Please check your personal hat address again", alertTitle: "Wrong domain!", okTitle: "OK", proceedCompletion: {() -> Void in return})
        }
        
        HatAccountService.logOnToHAT(userHATDomain: inputUserHATDomain.text!, successfulVerification: self.authoriseUser, failedVerification: failed)
    }
    
    // MARK: - View Controller functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // add keyboard handling
        self.addKeyboardHandling()
        self.hideKeyboardWhenTappedAround()
        
        // disable the navigation back button
        self.navigationItem.setHidesBackButton(true, animated:false)
        
        // add borders to the buttons
        self.getAHATButton.addBorderToButton(width: 1, color: .white)
        self.learnMoreButton.addBorderToButton(width: 1, color: .white)
        self.useWithoutHATButton.addBorderToButton(width: 1, color: .white)
        
        // set title
        self.title = NSLocalizedString("logon_label", comment:  "logon title")
        
        // format title label
        let textAttributesTitle = [
            NSForegroundColorAttributeName: UIColor.white,
            NSStrokeColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Open Sans", size: 32)!,
            NSStrokeWidthAttributeName: -1.0
            ] as [String : Any]
        
        let textAttributes = [
            NSForegroundColorAttributeName: UIColor.tealColor(),
            NSStrokeColorAttributeName: UIColor.tealColor(),
            NSFontAttributeName: UIFont(name: "Open Sans", size: 32)!,
            NSStrokeWidthAttributeName: -1.0
            ] as [String : Any]
        
        let partOne = NSAttributedString(string: "Rumpel ", attributes: textAttributesTitle)
        let partTwo = NSAttributedString(string: "Lite", attributes: textAttributes)
        let combination = NSMutableAttributedString()
        
        combination.append(partOne)
        combination.append(partTwo)
        self.labelTitle.attributedText = combination
        self.labelTitle.textAlignment = .center
        
        // move placeholder inside by 5 points
        self.inputUserHATDomain.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        
        // input
        inputUserHATDomain.placeholder = NSLocalizedString("hat_domain_placeholder", comment:  "user HAT domain")

        // button
        buttonLogon.setTitle(NSLocalizedString("logon_label", comment:  "username"), for: UIControlState())
        buttonLogon.backgroundColor = Constants.Colours.AppBase
        
        // Create a button bar for the number pad
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 30)
        
        var barButtonTitle = "Autofill"
        
        if let result = Helper.GetKeychainValue(key: Constants.Keychain.HATDomainKey) {
            
            barButtonTitle = result
        }

        // Setup the buttons to be put in the system.
        let autofillButton = UIBarButtonItem(title: barButtonTitle, style: .done, target: self, action: #selector(self.autofillPHATA))
        autofillButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Open Sans", size: 17.0)!, NSForegroundColorAttributeName: UIColor.white], for: .normal)
        toolbar.barTintColor = .black
        toolbar.setItems([autofillButton], animated: true)

        self.inputUserHATDomain.inputAccessoryView = toolbar
        self.inputUserHATDomain.inputAccessoryView?.backgroundColor = .black
        
        // app version
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            
            self.labelAppVersion.text = "v." + version
        }
        
        // add notification observer for the login in
        NotificationCenter.default.addObserver(self, selector: #selector(self.hatLoginAuth), name: NSNotification.Name(rawValue: Constants.Auth.NotificationHandlerName), object: nil)
        
        // set tint color, if translucent and the bar tint color of navigation bar
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.tealColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // when the view appears clear the text field. The user might pressed sing out, this field must not contain the previous address
        self.inputUserHATDomain.text = ""
    }

    /*
        Override and return false
        We have a segue in the storyboard, mainly for visual 
        We openSeque... after validation
    */
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any!) -> Bool {
        
        if identifier == "ShowTabBarController" {
            
            return false
        }
        
        return true
    }
    
    // MARK: - Accesory Input View Method
    
    /**
     Fills the domain text field with the user's domain
     */
    func autofillPHATA() {
        
        if let result = Helper.GetKeychainValue(key: Constants.Keychain.HATDomainKey) {
            
            self.inputUserHATDomain.text = result
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
        
        let authURL = NSURL(string: hatDomainURL)
        
        // open the log in procedure in safari
        safariVC = SFSafariViewController(url: authURL as! URL)
        if let vc: SFSafariViewController = self.safariVC {
            
            self.present(vc, animated: true, completion: nil)
        }        
    }
    
    /**
     The notification received from the login precedure.
     
     - parameter NSNotification: notification
     */
    @objc private func hatLoginAuth(notification: NSNotification) {
        
        // get the url form the auth callback
        let url = notification.object as! NSURL
        
        // first of all, we close the safari vc
        if let vc: SFSafariViewController = safariVC {
            
            vc.dismiss(animated: true, completion: nil)
        }
        
        HatAccountService.loginToHATAuthorization(userDomain: self.inputUserHATDomain.text!, url: url, selfViewController: self)
    }
    
    /**
     Saves the hatdomain from token to keychain for easy log in
     
     - parameter userDomain: The user's domain
     - parameter HATDomainFromToken: The HAT domain extracted from the token
     */
    func authoriseAppToWriteToCloud(_ userDomain: String,_ HATDomainFromToken: String) {
        
        HatAccountService.authoriseAppToWriteToCloud(userDomain, HATDomainFromToken, viewController: self)
    }
    
    // MARK: - Keyboard handling
    
    override func keyboardWillHide(sender: NSNotification) {
        
        self.hideKeyboardInScrollView(scrollView)
    }
    
    override func keyboardWillShow(sender: NSNotification) {
        
        self.showKeyboardInView(self.view, scrollView: self.scrollView, sender: sender)
    }
}
