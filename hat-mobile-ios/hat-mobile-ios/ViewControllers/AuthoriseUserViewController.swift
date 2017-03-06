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

// MARK: Class

/// Authorise view controller, really a blank view controller needed to present the safari view controller
class AuthoriseUserViewController: UIViewController {
    
    // MARK: - Variables
    
    /// The func to execute after completing the authorisation
    var completionFunc: ((Void) -> Void)? = nil

    /// The safari view controller that opened to authorise user again
    private var safari: SFSafariViewController? = nil
    
    // MARK: - View Controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
        // add notif observer
        NotificationCenter.default.addObserver(self, selector: #selector(dismissView), name: NSNotification.Name(Constants.NotificationNames.reauthorised.rawValue), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // build up the hat domain auth url
        let userDomain = HatAccountService.TheUserHATDomain()
        let hatDomainURL = "https://" + userDomain + "/hatlogin?name=" + Constants.Auth.ServiceName + "&redirect=" +
            Constants.Auth.URLScheme + "://" + Constants.Auth.LocalAuthHost
        
        if let authURL = URL(string: hatDomainURL) {
            
            // open the log in procedure in safari
            self.safari = SFSafariViewController(url: authURL)
            if self.safari != nil {
                
                self.present(self.safari!, animated: true, completion: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Dismiss view controller
    
    /**
     Dismisses view controller from view hierarchy
     
     - parameter notif: A Notification object that called this function
     */
    @objc private func dismissView(notif: Notification) {
        
        // get the url form the auth callback
        if let url = notif.object as? NSURL {
            
            // first of all, we close the safari vc
            if let vc: SFSafariViewController = safari {
                
                vc.dismiss(animated: true, completion: nil)
                vc.removeFromParentViewController()
            }
            
            let userDomain = HatAccountService.TheUserHATDomain()
            
            // authorize with hat
            HatAccountService.loginToHATAuthorization(userDomain: userDomain, url: url, selfViewController: nil, completion: self.completionFunc)
            
            self.removeViewController()
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(Constants.NotificationNames.reauthorised.rawValue), object: nil)
        }
    }

    class func setupAuthoriseViewController(view: UIView) -> AuthoriseUserViewController {
        
        let authorise = AuthoriseUserViewController()
        authorise.view.backgroundColor = .clear
        authorise.view.frame = CGRect(x: view.center.x - 50, y: view.center.y - 20, width: 100, height: 40)
        authorise.view.layer.cornerRadius = 15
        authorise.completionFunc = nil
        
        return authorise
    }
}
