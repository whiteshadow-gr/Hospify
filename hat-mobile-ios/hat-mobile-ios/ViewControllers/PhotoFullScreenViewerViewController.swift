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

class PhotoFullScreenViewerViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var imageURL: String?
    private var loadingRing: LoadingScreenWithProgressRingViewController? = nil
    
    var file: FileUploadObject?
    
    private var isUIHidden: Bool = false
    
    private let token = HATAccountService.getUsersTokenFromKeychain()
    
    private let userDomain = HATAccountService.TheUserHATDomain()

    @IBAction func deleteButtonAction(_ sender: Any) {
        
        if file != nil {
            
            func success(isSuccess: Bool, renewedUserToken: String?) {
                
                // refresh user token
                if renewedUserToken != nil {
                    
                    _ = KeychainHelper.SetKeychainValue(key: "UserToken", value: renewedUserToken!)
                }
                
                _ = self.navigationController?.popViewController(animated: true)
            }
            
            func fail(error: HATError) {
                
                _ = CrashLoggerHelper.hatErrorLog(error: error)
            }
            
            HATFileService.deleteFile(fileID: file!.fileID, token: self.token, userDomain: self.userDomain, successCallback: success, errorCallBack: fail)
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideUI))
        
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(gesture)
        
        if self.file != nil {
            
            let imageURL: String = "https://" + userDomain + "/api/v2/files/content/" + file!.fileID
            
            self.imageView!.downloadedFrom(url: URL(string: imageURL)!, completion: nil)
        } else if self.imageURL != nil {
            
            let url = URL(string: self.imageURL!)
            
            self.imageView.downloadedFrom(url: url!, completion: {
            
                self.deleteButton.isHidden = true
                self.deleteButton = nil
            })
        }
        
        self.view.backgroundColor = .black
        
        self.loadingRing = LoadingScreenWithProgressRingViewController.customInit(completion: 0, from: self.storyboard!)
        self.loadingRing!.view.backgroundColor = .clear
        self.loadingRing?.percentageLabel.isHidden = true
        self.loadingRing?.cancelButton.isHidden = true
        self.addViewController(self.loadingRing!)
    }
    
    @objc private func hideUI() {
        
        self.navigationController?.isNavigationBarHidden = !(self.isUIHidden)
        self.tabBarController?.tabBar.isHidden = !(self.isUIHidden)
        self.tabBarController?.hidesBottomBarWhenPushed = !(self.isUIHidden)
        if self.deleteButton != nil {
            
            self.deleteButton.isHidden = !(self.isUIHidden)
        }
        self.isUIHidden = !(self.isUIHidden)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }

}
