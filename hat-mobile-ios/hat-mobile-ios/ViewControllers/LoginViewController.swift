/** Copyright (C) 2016 HAT Data Exchange Ltd
 * SPDX-License-Identifier: AGPL-3.0
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * RumpelLite is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License
 * as published by the Free Software Foundation, version 3 of
 * the License.
 *
 * RumpelLite is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
 * the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General
 * Public License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
 */

import UIKit
import SwiftyJSON
import Alamofire
import SafariServices
import JWTDecode
import SwiftyRSA

// MARK: String extension

// any Extensions required
extension String {
    
    /**
     String extension to convert from base64Url to base64
     
     parameter s: The string to be converted
     
     returns: A Base64 String
    */
    func fromBase64URLToBase64(s: String) -> String {
        
        var s = s;
        if (s.characters.count % 4 == 2 ) {
            
            s = s + "=="
        }else if (s.characters.count % 4 == 3 ) {
            
            s = s + "="
        }
        
        s = s.replacingOccurrences(of: "-", with: "+")
        s = s.replacingOccurrences(of: "_", with: "/")
        
        return s
    }
}

// MARK: - Class

/// The Login View Controller
class LoginViewController: BaseViewController {
    
    // MARK: - IBOutlets
    
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
    var safariVC: SFSafariViewController?
    
    // MARK: - IBActions
    
    /**
     An action executed when the logon button is pressed
     
     - parameter sender: The object that calls this method
     */
    @IBAction func buttonLogonTouchUp(_ sender: AnyObject) {
        
        // trim values
        let hatDomain = Helper.TrimString(inputUserHATDomain.text!)
        
        // username guard
        guard let _userDomain = inputUserHATDomain.text, !hatDomain.isEmpty else {
            
            inputUserHATDomain.text = ""
            return
        }
        
        // authorise user
        authoriseUser(hatDomain: _userDomain)
    }
    
    // MARK: - View Controller functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // disable the navigation back button
        self.navigationItem.setHidesBackButton(true, animated:false)
        
        // set title
        self.title = NSLocalizedString("logon_label", comment:  "logon title")
        
        // add keyboard handling
        self.addKeyboardHandling()
        self.hideKeyboardWhenTappedAround()
        
        // screen title
        labelTitle.text = NSLocalizedString("login_screen_title", comment:  "screen title")
        labelTitle.textColor = UIColor.white
        labelTitle.textAlignment = NSTextAlignment.center
        labelTitle.font = UIFont.boldSystemFont(ofSize: 20)

        // screen sub title
        labelSubTitle.text = NSLocalizedString("login_screen_subtitle", comment:  "screen sub title")
        labelSubTitle.textColor = UIColor.white
        labelSubTitle.textAlignment = NSTextAlignment.center
        labelSubTitle.font = UIFont.boldSystemFont(ofSize: 12)
        
        // input
        inputUserHATDomain.placeholder = NSLocalizedString("hat_domain_placeholder", comment:  "user HAT domain")
        inputUserHATDomain.text = ""

        // button
        buttonLogon.setTitle(NSLocalizedString("logon_label", comment:  "username"), for: UIControlState())
        buttonLogon.backgroundColor = Constants.Colours.AppBase
        
        // app version
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            
            self.labelAppVersion.text = "v." + version
        }
        
        // add notification observer for the login in
        NotificationCenter.default.addObserver(self, selector: #selector(self.hatLoginAuth), name: NSNotification.Name(rawValue: Constants.Auth.NotificationHandlerName), object: nil)
    }

    /*
        Override and return false
        We have a seque in the storyboard, mainly for visual 
        We openSeque... after validation
    */
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any!) -> Bool {
        
        if identifier == "ShowTabBarController" {
            
            return false
        }
        
        return true
    }
    
    /**
     when in landscape mode, hide the logo to avoid it getting too small
     **/
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        // hide logo, for some crazy reason !
        coordinator.animate(alongsideTransition: nil, completion: {
            
            _ in
            
            //self.ivLogo.isHidden = UIDevice.current.orientation.isLandscape
        })
    }
    
    // MARK: - Authorisation functions
    
    /**
     Authorise user with the hat
     
     - parameter hatDomain: The phata address of the user
     */
    func authoriseUser(hatDomain: String) {

       // e.g. https://iostesting.hubofallthings.net/hatlogin?name=MarketSquare&redirect=com.hubofallthings.rumpellocationtracker://doSomething
        
        // build up the hat domain auth url
        let hatDomainURL =
            "https://" + // https
            hatDomain + // the user hat domain
            "/hatlogin?name=" + // param
            Constants.Auth.ServiceName + // the service name
            "&redirect=" + // redirect param
            Constants.Auth.URLScheme + // the url scheme for auth callback to app. We declare it in info.list
            "://" +
            Constants.Auth.LocalAuthHost// this is a ghost host. This can be anything
        
        let authURL = NSURL(string: hatDomainURL)
        
        // open the log in procedure in safari
        safariVC = SFSafariViewController(url: authURL as! URL)
        if let vc:SFSafariViewController = self.safariVC {
            
            self.present(vc, animated: true, completion: nil)
        }        
    }
    
    /**
     The notification received from the login precedure.
     
     - parameter NSNotification: notification
     */
    func hatLoginAuth(notification: NSNotification) {
        
        // get the url form the auth callback
        let url = notification.object as! NSURL
        
        // first of all, we close the safari vc
        if let vc:SFSafariViewController = safariVC {
            
            vc.dismiss(animated: true, completion: nil)
        }
        
        // get token out
        if let token = Helper.GetQueryStringParameter(url: url.absoluteString, param: Constants.Auth.TokenParamName) {
            
            // get the public key for this user. e.g. https://iostesting.hubofallthings.net/publickey
            // make asynchronous call
            // parameters..
            let parameters = ["": ""]
            // auth header
            let headers = ["Accept": Constants.ContentType.Text, "Content-Type": Constants.ContentType.Text]
            // HAT domain
            let hatDomain = Helper.TrimString(inputUserHATDomain.text!)

            if let url = Helper.TheUserHATDOmainPublicKeyURL(hatDomain) {
                
                //. application/json
                NetworkHelper.AsynchronousStringRequest(url, method: HTTPMethod.get, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.Text, parameters: parameters as Dictionary<String, AnyObject>, headers: headers) { (r: Helper.ResultTypeString) -> Void in
                    
                    switch r {
                    case .isSuccess(let isSuccess, _, let result):
                        
                        if isSuccess {
                            
                            // decode the token and get the iss out 
                            let jwt = try! decode(jwt: token)
                            
                            // guard for the issuer check, “iss” (Issuer)
                            guard let HATDomainFromToken = jwt.issuer else {

                                self.presentUIAlertOK(NSLocalizedString("error_label", comment: "error"), message: NSLocalizedString("auth_error_general", comment: "auth"))
                                return
                            }
                                                        
                            /*
                             The token will consist of header.payload.signature
                             To verify the token we use header.payload hashed with signature in base64 format
                             The public PEM string is used to verify also
                             */
                            let tokenAttr: [String] = token.components(separatedBy: ".")
                            
                            // guard for the attr length. Should be 3 [header, payload, signature]
                            guard tokenAttr.count == 3 else {
                                
                                self.presentUIAlertOK(NSLocalizedString("error_label", comment: "error"), message: NSLocalizedString("auth_error_general", comment: "auth"))
                                return
                            }
                            
                            // And then to access the individual parts of token
                            let header : String = tokenAttr[0]
                            let payload : String = tokenAttr[1]
                            let signature : String = tokenAttr[2]
                            
                            // decode signature from baseUrl64 to base64
                            let decodedSig = signature.fromBase64URLToBase64(s: signature)
                            
                            // data to be verified header.payload
                            let headerAndPayload = header + "." + payload
                            
                            // SwiftyRSA.verifySignatureString
                            let result: VerificationResult = SwiftyRSA.verifySignatureString(headerAndPayload, signature: decodedSig, publicKeyPEM: result, digestMethod: .SHA256)
                            
                            /*
                                if successful ,we performSegue to the map view
                                else, we display a message
                            */
                            if (result.isSuccessful) {
                                
                                self.authoriseAppToWriteToCloud(hatDomain, HATDomainFromToken)
                            } else {
                                
                                self.presentUIAlertOK(NSLocalizedString("error_label", comment: "error"), message: NSLocalizedString("auth_error_invalid_token", comment: "auth"))
                            }
                        } else {
                            
                            // alamo fire http fail
                            self.presentUIAlertOK(NSLocalizedString("error_label", comment: "error"), message: result)
                        }
                        
                    case .error(let error, let statusCode):
                        
                        let msg:String = Helper.ExceptionFriendlyMessage(statusCode, defaultMessage: error.localizedDescription)
                        self.presentUIAlertOK(NSLocalizedString("error_label", comment: "error"), message: msg)
                    }
                }
            }
        } else {

            // no token in url callback redirect
            self.presentUIAlertOK(NSLocalizedString("error_label", comment: "error"), message: NSLocalizedString("auth_error_no_token_in_callback", comment: "auth"))
        }
    }
    
    /**
     Saves the hatdomain from token to keychain for easy log in
     
     - parameter userDomain: The user's domain
     - parameter HATDomainFromToken: The HAT domain extracted from the token
     */
    func authoriseAppToWriteToCloud(_ userDomain:String,_ HATDomainFromToken:String) {
        
        // parameters..
        let parameters = ["": ""]
        
        // auth header
        let headers:[String: String] = Helper.ConstructRequestHeaders(Helper.TheMarketAccessToken())
        // construct url
        let url = Helper.TheAppRegistrationWithHATURL(userDomain)
        
        // make asynchronous call
        NetworkHelper.AsynchronousRequest(url, method: HTTPMethod.get, encoding: Alamofire.URLEncoding.default, contentType: "application/json", parameters: parameters, headers: headers) { (r: Helper.ResultType) -> Void in
            
            switch r {
            case .isSuccess(let isSuccess, _, let result):
                
                if isSuccess {
                    
                    // belt and braces.. check we have a message in the returned JSON
                    if result["message"].exists() {
                        
                        // save the hatdomain from the token to the device Keychain
                        if(Helper.SetKeychainValue(key: Constants.Keychain.HATDomainKey, value: HATDomainFromToken)) {
                            
                            self.performSegue(withIdentifier: "ShowTabBarController", sender: self)
                         
                        // else show error in the saving in keychain
                        } else {
                            
                            self.presentUIAlertOK(NSLocalizedString("error_label", comment: "error"), message: NSLocalizedString("auth_error_keychain_save", comment: "keychain"))
                        }
                    // No message field in JSON file
                    } else {
                        
                        self.presentUIAlertOK(NSLocalizedString("error_label", comment: "error"), message: "Message not found")
                    }
                // general error
                } else {
                    
                    self.presentUIAlertOK(NSLocalizedString("error_label", comment: "error"), message: result.rawString()!)
                }
                
            case .error(let error, let statusCode):
                
                //show error
                let msg:String = Helper.ExceptionFriendlyMessage(statusCode, defaultMessage: error.localizedDescription)
                self.presentUIAlertOK(NSLocalizedString("error_label", comment: "error"), message: msg)
            }
        }
    }
}
