//
//  TabBarViewController.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 15/11/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import UIKit

// MARK: Class

/// The UITabBarViewController
class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: - View controller functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // change tint color, the color of the selected icon in tab bar
        self.tabBar.tintColor = UIColor.init(colorLiteralRed: 0/255, green: 150/255, blue: 136/255, alpha: 1)
        // set delete to self in order to receive the calls from tab bar controller
        self.delegate = self
        
        // create bar button in navigation bar
        self.createBarButtons()
        
//        for fontFamilyName in UIFont.familyNames {
//            
//            for fontName in UIFont.fontNames(forFamilyName: fontFamilyName){
//                print("Family: %@    Font: %@", fontFamilyName, fontName)
//            }
//        }

        // set tint color, if translucent and the bar tint color of navigation bar
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.init(colorLiteralRed: 0/255, green: 150/255, blue: 136/255, alpha: 1)
        
        // change navigation bar title
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white,
             NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 21)!]
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Tab bar controller funtions
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if viewController is MapViewController {
            
            // set title in navigation bar
            self.navigationItem.title = "Location"
            
            // create buttons
            let button1 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(showSettingsViewController))
            let button2 = UIBarButtonItem(title: "Data", style: .plain, target: self, action: #selector(showDataViewController))
            let button3 = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(logoutUser))

            // add buttons to navigation bar
            self.navigationItem.leftBarButtonItems = [button1, button2]
            self.navigationItem.rightBarButtonItem = button3
        } else {
            
            // create buttons
            self.createBarButtons()
        }
    }
    
    // MARK: - Buttons functions
    
    /**
     Create default buttons in navigation bar
     */
    func createBarButtons() {
        
        // disable left navigation button
        self.navigationItem.leftBarButtonItems = nil
        // change title in navigation bar
        self.navigationItem.title = "Notables"
        
        // create buttons
        let button1 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(showSettingsViewController))
        let button2 = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(logoutUser))
        
        // add buttons to navigation bar
        self.navigationItem.leftBarButtonItem = button1
        self.navigationItem.rightBarButtonItem = button2
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
        
        self.performSegue(withIdentifier: "settingsSegue", sender: self)
    }
    
    /**
     Logout procedure
     */
    func logoutUser() -> Void {
        
        // create alert
        let alert = UIAlertController(title: NSLocalizedString("logout_label", comment:  "logout"), message: NSLocalizedString("logout_message_label", comment:  "logout message"), preferredStyle: .alert)

        // create yes button with action
        let yesButtonOnAlertAction = UIAlertAction(title: NSLocalizedString("yes_label", comment:  "yes"), style: .default)
        { (action) -> Void in
            
            // stop location updating
            let helper = MapViewController()
            helper.stopUpdating()
            
            // stop any timers
            helper.stopAnyTimers()
            
            // clear the user hat domain in keychain
            _ = Helper.ClearKeychainKey(key: Constants.Keychain.HATDomainKey)
            
            // reset the stack to avoid allowing back
            let controller = LoginViewController()
            _ = self.navigationController?.popToViewController(controller, animated: true)
        }
        
        // add actions to the alert
        alert.addAction(yesButtonOnAlertAction)
        alert.addAction(UIAlertAction(title: NSLocalizedString("no_label", comment:  "no"), style: UIAlertActionStyle.default, handler: nil))
        
        // present alert
        self.present(alert, animated: true, completion: nil)
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
