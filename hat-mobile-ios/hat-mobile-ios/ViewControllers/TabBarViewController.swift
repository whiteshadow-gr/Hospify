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

        // Do any additional setup after loading the view.
        
        // disable left navigation button
        self.navigationItem.leftBarButtonItems = nil
        // hide back button
        self.navigationItem.hidesBackButton = true
        
        // change tint color, the color of the selected icon in tab bar
        self.tabBar.tintColor = UIColor.tealColor()
        // set delete to self in order to receive the calls from tab bar controller
        self.delegate = self

        // set tint color, if translucent and the bar tint color of navigation bar
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.tealColor()
        
        // change navigation bar title
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white,
             NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 21)!]
        
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarViewController.logoutUser), name: NSNotification.Name("signOut"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
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
        
        // remove buttons on the left and right of the navigation bar
        self.navigationItem.leftBarButtonItems = nil
        self.navigationItem.rightBarButtonItems = nil
        
        if viewController is MapViewController {
            
            // set title in navigation bar
            self.navigationItem.title = "Location"
        } else if viewController is SocialFeedViewController {
            
            // set title in navigation bar
            self.navigationItem.title = "Social Data"
        } else if viewController is DataPlugsCollectionViewController {
            
            // set title in navigation bar
            self.navigationItem.title = "Data Plugs"
        } else {
            
            // change title in navigation bar
            self.navigationItem.title = "Home"
        }
        
        let button = UIBarButtonItem(image: UIImage(named: "Settings"), style: .plain, target: self, action: #selector(setUpActionViewController))
        
        // add buttons to navigation bar
        self.navigationItem.rightBarButtonItem = button
    }
    
    func setUpActionViewController() {
        
        if let viewController = self.selectedViewController {
            
            let alertController = UIAlertController(title: "Settings", message: nil, preferredStyle: .actionSheet)
            
            if viewController is MapViewController {
                
                let dataAction = UIAlertAction(title: "Data", style: .default, handler: {(alert: UIAlertAction) -> Void
                    
                    in
                    self.showDataViewController()
                })
                
                let settingsAction = UIAlertAction(title: "Location Settings", style: .default, handler: {(alert: UIAlertAction) -> Void
                    
                    in
                    self.showSettingsViewController()
                })
                
                alertController.addAction(dataAction)
                alertController.addAction(settingsAction)
                
            } else if viewController is SocialFeedViewController {
                
                let filterAction = UIAlertAction(title: "Filter by", style: .default, handler: {(alert: UIAlertAction) -> Void
                    
                    in
                    self.filterSocialFeed()
                })
                
                alertController.addAction(filterAction)
            }
            
            let logOutAction = UIAlertAction(title: "Log out", style: .default, handler: {(alert: UIAlertAction) -> Void
                
                in
                TabBarViewController.logoutUser(from: self)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(logOutAction)
            alertController.addAction(cancelAction)
            
            // if user is on ipad show as a pop up
            if UI_USER_INTERFACE_IDIOM() == .pad {
                
                alertController.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
                alertController.popoverPresentationController?.sourceView = self.view
            }
            
            // present alert controller
            self.navigationController!.present(alertController, animated: true, completion: nil)
        }
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
        
        let yesAction = { () -> Void in
            
            // delete keys from keychain
            let clearUserToken = KeychainHelper.ClearKeychainKey(key: "UserToken")
            _ = KeychainHelper.SetKeychainValue(key: "logedIn", value: "false")
            
            if (!clearUserToken) {
                
                // show alert that the log out was not completed for some reason
                // MARK: TODO
            }
            
            // reset the stack to avoid allowing back
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            viewController.navigationController?.title = ""
            let navigation = viewController.navigationController
            _ = viewController.navigationController?.popToRootViewController(animated: false)
            navigation?.pushViewController(loginViewController, animated: false)
        }
        
        viewController.createClassicAlertWith(alertMessage: NSLocalizedString("logout_message_label", comment:  "logout message"),
                                    alertTitle: NSLocalizedString("logout_label", comment:  "logout"),
                                    cancelTitle: NSLocalizedString("no_label", comment:  "no"),
                                    proceedTitle: NSLocalizedString("yes_label", comment:  "yes"),
                                    proceedCompletion: yesAction,
                                    cancelCompletion: {() -> Void in return})
    }
}
