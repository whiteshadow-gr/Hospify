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

import HatForIOS
import SwiftyJSON

// MARK: Class

class PhataPictureViewController: UIViewController {
    
    // MARK: - Variables
    
    var profile: HATProfileObject? = nil
    private let userDomain = HATAccountService.TheUserHATDomain()
    private let userToken = HATAccountService.getUsersTokenFromKeychain()
    private var loadingView: UIView = UIView()
    /// A dark view covering the collection view cell
    private var darkView: UIView = UIView()
    
    // MARK: - IBoutlets

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var customSwitch: CustomSwitch!
    
    // MARK: - IBActions
    
    /**
     Sets the isPrivate according to the value of the switch
     
     - parameter sender: The object that calls this function
     */
    @IBAction func customSwitchAction(_ sender: Any) {
        
        self.profile?.data.facebookProfilePhoto.isPrivate = !(self.customSwitch.isOn)
    }
    
    /**
     Sends the profile data to hat
     
     - parameter sender: The object that calls this function
     */
    @IBAction func saveButtonAction(_ sender: Any) {
        
        self.darkView = UIView(frame: self.view.frame)
        self.darkView.backgroundColor = .black
        self.darkView.alpha = 0.4
        
        self.view.addSubview(self.darkView)
        
        self.loadingView = UIView.createLoadingView(with: CGRect(x: (self.view?.frame.midX)! - 70, y: (self.view?.frame.midY)! - 15, width: 140, height: 30), color: .tealColor(), cornerRadius: 15, in: self.view, with: "Updating profile...", textColor: .white, font: UIFont(name: "OpenSans", size: 12)!)
        
        func tableExists(dict: Dictionary<String, Any>, renewedUserToken: String?) {
            
            HATAccountService.postProfile(userDomain: userDomain, userToken: userToken, hatProfile: self.profile!, successCallBack: {
                
                self.loadingView.removeFromSuperview()
                self.darkView.removeFromSuperview()
                
                _ = self.navigationController?.popViewController(animated: true)
            }, errorCallback: {error in
                
                self.loadingView.removeFromSuperview()
                self.darkView.removeFromSuperview()
                
                _ = CrashLoggerHelper.hatTableErrorLog(error: error)
            })
        }
        
        HATAccountService.checkHatTableExistsForUploading(userDomain: userDomain, tableName: "profile", sourceName: "rumpel", authToken: userToken, successCallback: tableExists, errorCallback: {_ in
            
            self.loadingView.removeFromSuperview()
            self.darkView.removeFromSuperview()
        })
    }
    
    // MARK: - View controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.customSwitch.isOn = !((profile?.data.facebookProfilePhoto.isPrivate)!)
        
        DispatchQueue.main.async {
            
            self.imageView.layer.masksToBounds = true
            self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
        }
        
        let userDomain = HATAccountService.TheUserHATDomain()
        let userToken = HATAccountService.getUsersTokenFromKeychain()
        
        func tableNotFound(error: HATTableError) {
            
            self.createClassicOKAlertWith(alertMessage: "Please enable Facebook data plug to get your Facebook image", alertTitle: "Facebook data plug disabled", okTitle: "Ok", proceedCompletion: {})
        }
        
        func facebookActive(active: Bool) {
            
            if active {
                
                func tableFound(tableID: NSNumber, renewedToken: String?) {
                    
                    func tableValues(values: [JSON], refreshedToken: String?) {
                        
                        if let tempURL = values[0].dictionaryValue["data"]?.dictionaryValue["profile_picture"]?.dictionaryValue["url"]?.stringValue {
                            
                            if let url = URL(string: tempURL) {
                                
                                self.imageView.downloadedFrom(url: url, completion: {
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.imageView.layer.masksToBounds = true
                                        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
                                    }
                                })
                            }
                        }
                    }
                    
                    HATAccountService.getHatTableValues(token: userToken, userDomain: userDomain, tableID: tableID, parameters: ["X-Auth-Token" : userToken], successCallback: tableValues, errorCallback: tableNotFound)
                }
                
                HATAccountService.checkHatTableExists(userDomain: userDomain, tableName: "profile_picture", sourceName: "facebook", authToken: userToken, successCallback: tableFound, errorCallback: tableNotFound)
            } else {
                
                self.createClassicOKAlertWith(alertMessage: "Please enable Facebook data plug to get your Facebook image", alertTitle: "Facebook data plug disabled", okTitle: "Ok", proceedCompletion: {})
            }
        }
        
        func facebookError(error: DataPlugError) {
            
            self.createClassicOKAlertWith(alertMessage: "Please enable Facebook data plug to get your Facebook image", alertTitle: "Facebook data plug disabled", okTitle: "Ok", proceedCompletion: {})
            
            _ = CrashLoggerHelper.dataPlugErrorLog(error: error)
        }
        
        HATFacebookService.isFacebookDataPlugActive(token: userToken, successful: facebookActive, failed: facebookError)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }

}
