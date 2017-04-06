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

// MARK: Class

/// The UITabBarViewController
class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: - View controller functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // disable left navigation button
        self.navigationItem.leftBarButtonItems = nil
        // hide back button
        self.navigationItem.hidesBackButton = true
        
        // change tint color, the color of the selected icon in tab bar
        self.tabBar.tintColor = UIColor.tealColor()
        // set delete to self in order to receive the calls from tab bar controller
        self.delegate = self
        
        // change navigation bar title
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white,
             NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 21)!]
        
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarViewController.logoutUser), name: NSNotification.Name("signOut"), object: nil)        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // create bar button in navigation bar
        self.createBarButtonsFor(viewController: self.selectedViewController)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Tab bar controller funtions
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        self.createBarButtonsFor(viewController: self.selectedViewController)
    }
    
    // MARK: - Buttons functions
    
    /**
     Create default buttons in navigation bar
     */
    func createBarButtonsFor(viewController: UIViewController?) {
        
        if viewController != nil {
            
            // remove buttons on the left and right of the navigation bar
            viewController!.navigationItem.leftBarButtonItems = nil
            viewController!.navigationItem.rightBarButtonItems = nil
            
            let button = UIBarButtonItem(image: UIImage(named: "Settings"), style: .plain, target: self, action: #selector(setUpActionViewController))
            
            // add buttons to navigation bar
            viewController!.navigationItem.rightBarButtonItem = button
        }
    }
    
    /**
     Set's up the bar buttons for tab bar
     */
    func setUpActionViewController() {
        
        let alertController = UIAlertController(title: "Settings", message: nil, preferredStyle: .actionSheet)
        
        let logOutAction = UIAlertAction(title: "Log out", style: .default, handler: {[weak self] (alert: UIAlertAction) -> Void in
            
            if self != nil {
                
                TabBarViewController.logoutUser(from: self!)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addActions(actions: [logOutAction, cancelAction])
        alertController.addiPadSupport(barButtonItem: self.navigationItem.rightBarButtonItem!, sourceView: self.view)
        
        // present alert controller
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    /**
     Goes to data ViewController
     */
    func showDataViewController() {
        
        self.performSegue(withIdentifier: "dataSegue", sender: self)
    }
    
    /**
     Goes to settings ViewController
     */
    func showSettingsViewController() {
        
        NotificationCenter.default.post(name: NSNotification.Name("goToSettings"), object: nil)
    }
    
    /**
     Sends a notification to social feed to show the alert controller to select the filter
     */
    func filterSocialFeed() {
        
        NotificationCenter.default.post(name: NSNotification.Name("filterSocialFeed"), object: nil)
    }
    
    /**
     Logout procedure
     */
    class func logoutUser(from viewController: UIViewController) -> Void {
        
        let yesAction = {() -> Void in
            
            // delete keys from keychain
            _ = KeychainHelper.ClearKeychainKey(key: "UserToken")
            _ = KeychainHelper.SetKeychainValue(key: "logedIn", value: "false")
            
            // reset the stack to avoid allowing back
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            viewController.navigationController?.title = ""
            let navigation = viewController.navigationController
            _ = viewController.navigationController?.popToRootViewController(animated: false)
            navigation?.pushViewController(loginViewController, animated: false)
        }
        
        viewController.createClassicAlertWith(alertMessage: NSLocalizedString("logout_message_label", comment:  "logout message"), alertTitle: NSLocalizedString("logout_label", comment:  "logout"), cancelTitle: NSLocalizedString("no_label", comment:  "no"), proceedTitle: NSLocalizedString("yes_label", comment:  "yes"), proceedCompletion: yesAction, cancelCompletion: {})
    }
}
