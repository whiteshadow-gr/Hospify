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
import SwiftSpinner
import SwiftyJSON
import Alamofire



class LoginViewController: BaseViewController {
    
    @IBOutlet weak var buttonLogon: UIButton!
    @IBOutlet weak var inputUserHATDomain: UITextField!
    @IBOutlet weak var labelAppVersion: UILabel!
    
    typealias MarketAccessToken = String

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = NSLocalizedString("logon_label", comment:  "logon title")
        
        // input
        inputUserHATDomain.placeholder = NSLocalizedString("hat_domain_placeholder", comment:  "user HAT domain")
        
        // button
        buttonLogon.setTitle(NSLocalizedString("logon_label", comment:  "username"), forState: UIControlState.Normal)
        
        // TODO... .debug
        inputUserHATDomain.text = ""
        
        // app version
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            self.labelAppVersion.text = "v" + version
        }
    }
    
    // logon button event
    @IBAction func buttonLogonTouchUp(sender: AnyObject) {
        
        // trim values
        let hatDomain = Helper.TrimString(inputUserHATDomain.text!)
        
        // username guard
        guard let _userDomain = inputUserHATDomain.text where !hatDomain.isEmpty else {
            inputUserHATDomain.text = ""
            return
        }
        
        
        SwiftSpinner.useContainerView(self.view)
        SwiftSpinner.show(NSLocalizedString("attempting_to_login", comment:  "login"))
     
        // parameters..
        let parameters = ["": ""]
        
        // auth header
        let headers:[String: String] = Helper.ConstructRequestHeaders(Helper.TheMarketAccessToken())
        // construct url
        let url = Helper.TheAppRegistrationWithHATURL(_userDomain)
        
        // make asynchronous call
        NetworkHelper.AsynchronousRequest(url, method: Alamofire.Method.GET, encoding: Alamofire.ParameterEncoding.URLEncodedInURL, contentType: "application/json", parameters: parameters, headers: headers) { (r: Helper.ResultType) -> Bool in
            
            // the result from asynchronous call to login
            SwiftSpinner.hide()
            
            switch r {
            case .IsSuccess(let isSuccess, _, let result):
                if isSuccess{
                    
                    // Note: as? ..i know it's a  JSON.. so cast
                    if let theResult:JSON = result as JSON{
                        //print("JSON res: \(theResult)")
                        
                        // belt and braces.. check we have a message in the returned JSON
                        if theResult["message"].isExists()
                        {
                            // save user HAT domain
                            let preferences = NSUserDefaults.standardUserDefaults()
                            preferences.setObject(_userDomain, forKey: Constants.Preferences.UserHATDomain)
                            
                            // seque
                            self.performSegueWithIdentifier("ShowMapsViewController", sender: self)
                        }else{
                            self.presentUIAlertOK(NSLocalizedString("error_label", comment:  "error"), message: "Message not found")
                        }
                        
                    }
                }else{
                    self.presentUIAlertOK(NSLocalizedString("error_label", comment:  "error"), message: result.rawString()!)
                }
                
                return true
            case .Error(let error, let statusCode):
                if let error:NSError = error as NSError{
                    //print("error res: \(error)")
                    let msg:String = Helper.ExceptionFriendlyMessage(statusCode, defaultMessage: error.localizedDescription)
                    self.presentUIAlertOK(NSLocalizedString("error_label", comment:  "error"), message: msg)
                }
                return false
            }
            
        }
        
    }
    

    /*
        Override and return false
        We have a seque in the storyboard, mainly for visual 
        We openSeque... after validation
    */
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        
        if identifier == "ShowMapsViewController" {
            return false
        }
        return true
    }
    
    
    
    
    
}

